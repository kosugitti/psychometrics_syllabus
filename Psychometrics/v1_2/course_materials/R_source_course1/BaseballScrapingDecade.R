rm(list = ls())
library(tidyverse)
library(rvest)
library(summarytools)

# データ
## プレイヤーデータ
address1 <- "https://baseball-data.com/player/"
## 打者/投手成績
address2 <- "https://baseball-data.com/stats/"
## チームID
tID <- c("c", "t", "yb", "g", "d", "s", "h", "l", "e", "bs", "f", "m")
# tID <- "c"
## 収集年度
YEARS <- 25
# YEARS <- 11:12

## 基本となるURL
baseURL <- "https://baseball-data.com/"
## 年俸
saralyURL <- "/ranking-salary/"
## 野手
hitterURL <- "/stats/hitter-"
## 投手
pitcherURL <- "/stats/pitcher-"

dat1 <- data.frame()
dat2 <- data.frame()
dat3 <- data.frame()

for (Y in YEARS) {
    for (i in 1:NROW(tID)) {
        # プレイヤーデータ
        if (Y == 25) {
            tmp <- ""
        } else {
            tmp <- Y
        }
        url1 <- paste0(baseURL, tmp, saralyURL, tID[i], "/")
        tmp.dat <- read_html(url1) %>%
            html_table() %>%
            as.data.frame()
        tmp.dat$team <- tID[i]
        tmp.dat$Year <- paste0(20, Y, "年度")
        dat1 <- rbind(dat1, tmp.dat)
        print(paste0(Y, "年度 チーム ", tID[i], " 年俸データ get!"))
        Sys.sleep(1)
        # 打者成績
        url2 <- paste0(baseURL, Y, hitterURL, tID[i], "/")
        tmp.dat <- read_html(url2) %>%
            html_table() %>%
            as.data.frame() %>%
            slice(1:(n() - 1))
        tmp.dat$team <- tID[i]
        tmp.dat$Year <- paste0(20, Y, "年度")
        dat2 <- rbind(dat2, tmp.dat)
        print(paste0(Y, "年度 チーム ", tID[i], " 打者データ get!"))
        Sys.sleep(1)
        # 投手成績
        url3 <- paste0(baseURL, Y, pitcherURL, tID[i], "/")
        tmp.dat <- read_html(url3) %>%
            html_table() %>%
            as.data.frame() %>%
            slice(1:(n() - 1))
        tmp.dat$team <- tID[i]
        tmp.dat$Year <- paste0(20, Y, "年度")
        dat3 <- rbind(dat3, tmp.dat)
        print(paste0(Y, "年度 チーム ", tID[i], " 投手データ get!"))
        Sys.sleep(1)
    }
    print(paste0(Y, "年度データ収集　Done."))
}




# プレイヤーデータ整形 ----------------------------------------------------------------------

dat1 %>%
    mutate(
        Rank = as.numeric(.$順位),
        Name = as.factor(.$選手名),
        team = as.factor(.$team),
        salary = str_replace(.$年俸.推定., "万円", "") %>% str_replace(",", "") %>% as.numeric(),
        position = .$守備,
        years = str_replace(.$年数, "年", "") %>% as.numeric(),
        height = str_replace(.$身長, "cm", "") %>% as.numeric(),
        weight = str_replace(.$体重, "kg", "") %>% as.numeric(),
        bloodType = as.factor(.$血液型),
        throw.by = str_sub(.$投打, start = 1, end = 1) %>% as.factor(),
        batting.by = str_sub(.$投打, start = 2, end = 2) %>% as.factor(),
        birth.place = .$出身地,
        birth.day = lubridate::ymd(.$生年月日)
    ) %>%
    dplyr::select(
        Year, Name, team, Rank, salary, position, years, height, weight, bloodType, birth.place, birth.day
    ) %>%
    as_tibble() -> dat1

# 野手データ整形 ----------------------------------------------------------------------

dat2 %>%
    as_tibble() %>%
    mutate_at(c(3:20), funs(as.numeric(.))) %>%
    mutate(team = as.factor(team)) %>%
    rename(Name = 選手名) -> dat2

# 投手データ整形 ----------------------------------------------------------------------

dat3 %>%
    as_tibble() %>%
    mutate_at(c(3:20), funs(as.numeric(.))) %>%
    mutate(team = as.factor(team)) %>%
    rename(
        Name = 選手名,
        登板数 = 試合
    ) -> dat3



# 統合 ----------------------------------------------------------------------

dat1 %>%
    full_join(dat2, by = c("Name", "Year", "team")) %>%
    full_join(dat3, by = c("Name", "Year", "team")) %>%
    mutate(
        "Name" = as.factor(Name),
        "team" = as.factor(team),
        "position" = as.factor(position),
        "birth.place" = as.factor(birth.place)
    ) %>%
    mutate(team = fct_recode(team,
        "Tigers" = "t", "Carp" = "c", "Giants" = "g", "DeNA" = "yb",
        "Dragons" = "d", "Swallows" = "s", "Softbank" = "h", "Lions" = "l",
        "Eagles" = "e", "Orix" = "bs", "Fighters" = "f", "Lotte" = "m"
    )) %>%
    # 基本情報がない選手は削除
    filter(!is.na(salary)) %>%
    # 文字化け対策
    rename(
        セーブ = セlブ,
        ホールド = ホlルド
    ) %>%
    # 2020年度から「型」が抜けた
    mutate(
        bloodType = fct_recode(bloodType, O型 = "O", A型 = "A", B型 = "B", AB型 = "AB")
    ) %>%
    mutate(
        UniformNum = if_else(is.na(背番号.x), 背番号.y, 背番号.x),
        Games = if_else(is.na(試合), 登板数, 試合)
    ) %>%
    rename(
        Hit = 安打,
        AtBats = 打数,
        HR = 本塁打,
        Win = 勝利,
        Lose = 敗北,
        Save = セーブ,
        Hold = ホールド
    ) %>%
    dplyr::select(
        Year,
        Name, team, salary, bloodType, height, weight, UniformNum,
        position, Games,
        AtBats, Hit, HR, Win, Lose, Save, Hold
    ) %>%
    filter(!is.na(UniformNum)) %>%
    filter(!is.na(Games)) -> baseball

# write_csv(baseball, file = "Baseball22.csv")
# rm(list=ls())
