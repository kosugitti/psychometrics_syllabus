library(rvest)
p.data <- read_html("http://baseball-data.com/ranking-salary/all/p.html") #ピッチャーの年俸など
h.data <- read_html("http://baseball-data.com/ranking-salary/all/h.html") #野手のそれ
avg5 <- read_html("http://baseball-data.com/stats/hitter2-all/avg-5.html") #規定打数1/3以上の打者基本成績
era5 <- read_html("http://baseball-data.com/stats/pitcher2-all/era-5.html") #規定投球回1/3以上の投手基本成績
p.df <- as.data.frame(html_table(p.data,head=T))
head(p.df)
library(stringr) # 文字列操作パッケージ
p.df$順位 <- NULL
p.df$チーム <- as.factor(p.df$チーム) # チーム名はfactor型
#年俸の「万円」と「,」を除外して数字に
p.df$年俸.推定. <- str_replace(p.df$年俸.推定.,"万円","") %>% str_replace(",","") %>% as.numeric() 
p.df$年数 <- str_replace(p.df$年数,"年","") %>% as.numeric() #年数の「年」を除外して数字に
p.df$年齢 <- str_replace(p.df$年齢,"歳","") %>% as.numeric() #年齢の「歳」を除外して数字に
# 生年月日を"/"で区切って数値データにし，行列に組み上げてからデータフレームとして元データに結合
birth.data <- p.df$生年月日 %>% str_split("/") %>% unlist()  %>% as.numeric() %>% matrix(ncol=3,byrow=T) %>% as.data.frame()
p.df <- cbind(p.df,birth.data)
p.df$身長 <- str_replace(p.df$身長,"cm","") %>% as.numeric() #身長の「cm」を除外して数字に
p.df$体重 <- str_replace(p.df$体重,"kg","") %>% as.numeric() #体重の「kg」を除外して数字に1
p.df$血液型 <- as.factor(p.df$血液型)
p.df$投 <- str_sub(p.df$投打, start=1, end=1) %>% as.factor() #投げる腕を切り出してfactor型に
p.df$打 <- str_sub(p.df$投打, start=2, end=2) %>% as.factor() #打つ腕を切り出してfactor型に
p.df$出身地 <- as.factor(p.df$出身地)
p.df$守備 <- NULL #データを作り変えた変数は除外しておく
p.df$生年月日 <- NULL
p.df$投打 <- NULL
# 変数名を英語にしておく
names(p.df) <- c("name","team","pay","year","age","height","weight","blood","home","BirthY","BirthM","BirthD","throw","hit")
summary(p.df) # 確認
h.df <- as.data.frame(html_table(h.data,head=T))
h.df$順位 <- NULL
h.df$チーム <- as.factor(h.df$チーム) # チーム名はfactor型
#年俸の「万円」と「,」を除外して数字に
h.df$年俸.推定. <- str_replace(h.df$年俸.推定.,"万円","") %>% str_replace(",","") %>% as.numeric() 
h.df$年数 <- str_replace(h.df$年数,"年","") %>% as.numeric() #年数の「年」を除外して数字に
h.df$年齢 <- str_replace(h.df$年齢,"歳","") %>% as.numeric() #年齢の「歳」を除外して数字に
# 生年月日を"/"で区切って数値データにし，行列に組み上げてからデータフレームとして元データに結合
birth.data <- h.df$生年月日 %>% str_split("/") %>% unlist()  %>% as.numeric() %>% matrix(ncol=3,byrow=T) %>% as.data.frame()
h.df <- cbind(h.df,birth.data)
h.df$身長 <- str_replace(h.df$身長,"cm","") %>% as.numeric() #身長の「cm」を除外して数字に
h.df$体重 <- str_replace(h.df$体重,"kg","") %>% as.numeric() #体重の「kg」を除外して数字に1
h.df$血液型 <- as.factor(h.df$血液型)
h.df$投 <- str_sub(h.df$投打, start=1, end=1) %>% as.factor() #投げる腕を切り出してfactor型に
h.df$打 <- str_sub(h.df$投打, start=2, end=2) %>% as.factor() #打つ腕を切り出してfactor型に
h.df$出身地 <- as.factor(h.df$出身地)
h.df$守備 <- NULL #データを作り変えた変数は除外しておく
h.df$生年月日 <- NULL
h.df$投打 <- NULL
names(h.df) <- c("name","team","pay","year","age","height","weight","blood","home","BirthY","BirthM","BirthD","throw","hit")
summary(h.df) # 確認
#打者
avg5.df <- as.data.frame(html_table(avg5,head=T))
avg5.df <- avg5.df[-nrow(avg5.df),]
avg5.df$順位 <- NULL
avg5.df$チーム <- as.factor(avg5.df$チーム)
avg5.df[3:24] <- apply(avg5.df[3:24],2,as.numeric) #あとは数字変数
# 変数名の変更
#  "選手名" "チーム" "打率"   "試合"   "打席数" "打数"   "得点"   "安打"   "二塁打" "三塁打" "本塁打" "塁打"  
#  "打点"   "盗塁"   "盗塁刺" "犠打"   "犠飛"   "四球"   "敬遠"   "死球"   "三振"   "併殺打" "長打率" "出塁率"
names(avg5.df) <- c("name","team","BA","games","PA","AB","R","Hit","Double","Three","HR","TB",
                    "RBI","steal","CS","SH","SF","BB","HWHI","HBP","K","DP","SLG","OBP")

#投手
era5.df <- as.data.frame(html_table(era5,head=T))
era5.df <- era5.df[-nrow(era5.df),]
era5.df$順位 <- NULL
era5.df$チーム <- as.factor(era5.df$チーム)
era5.df[3:25] <- apply(era5.df[3:25],2,as.numeric) #あとは数字変数
# 変数名の変更
#  "選手名"   "チーム"   "防御率"   "試合"     "勝利"     "敗北"     "セlブ"    "ホlルド"  "HP"      
#  "完投"     "完封勝"   "無四球"   "勝率"     "打者"     "投球回"   "被安打"   "被本塁打" "与四球"   "敬遠"    
#  "与死球"   "奪三振"   "暴投"     "ボlク"    "失点"     "自責点"
names(era5.df) <- c("name","team","ERA","games","win","lose","save","hold","HP",
                    "CG","SHO","No.walks","win.rate","batter","times","hits","HR","BB","HWHI",
                    "DB","K","W.pitch","balk","R","ER")
batter <- merge(h.df,avg5.df,by="name")
pitcher <- merge(p.df,era5.df,by="name")

bat <- subset(batter,select=c("name","team.x","pay","height","weight","PA","AB","HR","K"))
names(bat) <-c("name","team","pay","height","weight","PA","AB","HR","K")
bat$league <- factor(ifelse(bat$team %in% c("阪神","巨人","ヤクルト","中日","DeNA","広島"),1,2),labels = c("Central","Pacific"))
bat <- bat[c("name","team","league","height","weight","PA","AB","HR","K","pay")]
# write.table(bat,file="ball2017.csv",sep=",",row.names = F)

