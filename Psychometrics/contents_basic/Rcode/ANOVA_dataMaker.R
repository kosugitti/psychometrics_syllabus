#
# 分散分析の仮想データをつくる関数群
#   NHST_sampleMaker.R の分散分析の節を関数にまとめ直したもの
#
# 使い方の例
#   dat <- make_anova_data("AsB", n = 10, A = TRUE, B = FALSE, AB = TRUE)
#   anova_check(dat)                         # aov で各効果の p 値を確認
#   wide <- make_anova_data("sAB", n = 10, levels = c(2, 3), A = TRUE,
#                           format = "wide", match = TRUE, seed = 1)
#   anovakun(wide[, -1], "sAB", 2, 3)        # anovakun にそのまま渡せる
#
# make_anova_data() の引数(カッコ内は既定値)
#   design  : anovakun の型指定。s の左が群間要因，右が群内要因。要因は A〜C の3つまで
#             例: "As"(一要因群間)，"sA"(一要因群内)，"ABs"(二要因群間)，"AsB"(混合)，
#                 "sAB"(二要因群内)，"ABCs"，"ABsC"，"AsBC"，"sABC"
#   n       : 群間の各セルの参加者数。群間要因がない計画では全体の参加者数 (10)
#   levels  : 各要因の水準数を A, B, C の順に並べたベクトル。例: c(2, 3) (すべて2水準)
#   A, B, C : 主効果の有無。TRUE なら es の大きさの効果を入れる。数値を書けばその大きさになる (FALSE)
#   AB, AC, BC : 二次の交互作用の有無。書き方は主効果と同じ (FALSE)
#   ABC     : 三次の交互作用の有無。書き方は主効果と同じ (FALSE)
#   es      : TRUE と書いた効果の大きさ。標準偏差 sigma を単位とする (0.8)
#             主効果は「両端の水準の平均値の差」が es * sigma になる(3水準以上は等間隔)
#             交互作用は交差型で，両端の水準どうしの単純効果が es * sigma と -es * sigma に分かれる
#   mu      : 全体平均 (50)
#   sigma   : 各測定値の標準偏差 (10)
#   rho     : 群内要因の測定値どうしの相関。大きいほど個人差が大きい。群内要因がなければ使わない (0.5)
#   digits  : 測定値を丸める小数点以下の桁数。0 なら整数 (0)
#   format  : 返すデータの形。"long" は1行1測定値(ggplot や aov 向き)，
#             "wide" は1行1人で群内の水準の組み合わせが列になる(anovakun 向き) ("long")
#   match   : TRUE なら，指定した効果だけが有意で，それ以外は有意でないデータになるまで乱数の種を変える (FALSE)
#   alpha   : match = TRUE のときの有意水準 (0.05)
#   max_try : match = TRUE のときに種を試す回数の上限 (1000)
#   seed    : 乱数の種。match = TRUE のときは探し始める種。使った種は attr(データ, "seed") で取り出せる (NULL)
#
# anova_check() の引数
#   long    : make_anova_data() が format = "long" で返したデータ。aov で分散分析し，各効果の p 値を返す
#             (球面性の補正はしない)
#
# to_wide() の引数
#   long    : make_anova_data() が format = "long" で返したデータ。anovakun 向きの横長の形にして返す
#

# 準備 ----------------------------------------------------------------------
pacman::p_load(dplyr, tidyr)

# 型指定の読み取り ----------------------------------------------------------------
# "AsB" のような anovakun の型指定を，群間要因と群内要因に分ける
parse_design <- function(design) {
  if (!grepl("^[A-C]*s[A-C]*$", design)) {
    stop("design は anovakun の型指定(例: \"As\", \"sAB\", \"AsBC\")で，要因は A〜C の3つまでです。")
  }
  parts <- strsplit(design, "s", fixed = TRUE)[[1]]
  between <- if (length(parts) >= 1 && nchar(parts[1]) > 0) strsplit(parts[1], "")[[1]] else character(0)
  within <- if (length(parts) >= 2 && nchar(parts[2]) > 0) strsplit(parts[2], "")[[1]] else character(0)
  factors <- c(between, within)
  if (length(factors) == 0) {
    stop("要因が1つもありません。")
  }
  if (!identical(sort(factors), LETTERS[seq_along(factors)])) {
    stop("要因は A から順に，重複なく使ってください(例: \"ABs\" はよいが \"ACs\" は不可)。")
  }
  return(list(between = between, within = within, factors = sort(factors)))
}

# 効果の大きさの読み取り --------------------------------------------------------------
# TRUE なら es，数値ならその値，FALSE なら 0 にする
effect_size <- function(flag, es) {
  if (isTRUE(flag)) {
    return(es)
  }
  if (is.numeric(flag)) {
    return(flag)
  }
  return(0)
}

# 水準の得点 ------------------------------------------------------------------------
# k 水準を -1 から 1 まで等間隔に並べた得点(平均0)
level_scores <- function(k) {
  return(seq(-1, 1, length.out = k))
}

# データの生成 ---------------------------------------------------------------------
# design : anovakun の型指定。s の左が群間要因，右が群内要因
# n      : 群間の各セル(群間要因がなければ全体)の参加者数
# levels : 各要因の水準数。A, B, C の順。省略時はすべて2水準
# A, B, C, AB, AC, BC, ABC : 効果の有無。TRUE なら es の大きさ，数値ならその大きさ
# es     : TRUE のときの効果の大きさ(標準偏差 sigma を単位とする)
#          主効果は「両端の水準の平均値の差」が es * sigma になる
#          交互作用は，両端の水準どうしの単純効果が es * sigma と -es * sigma に分かれる交差型
# mu, sigma : 全体平均と，各測定値の標準偏差
# rho    : 群内要因の測定値どうしの相関(個人差の大きさ)
# digits : 丸める桁数
# format : "long"(1行1測定値)か "wide"(1行1人。anovakun にそのまま渡せる形)
# match  : TRUE なら，指定した効果だけが有意になる乱数の種を探す
# alpha, max_try : match のときの有意水準と，種を試す回数の上限
# seed   : 乱数の種。match = TRUE のときは探し始める種
make_anova_data <- function(design, n = 10, levels = NULL,
                            A = FALSE, B = FALSE, C = FALSE,
                            AB = FALSE, AC = FALSE, BC = FALSE, ABC = FALSE,
                            es = 0.8, mu = 50, sigma = 10, rho = 0.5, digits = 0,
                            format = c("long", "wide"),
                            match = FALSE, alpha = 0.05, max_try = 1000, seed = NULL) {
  format <- match.arg(format)
  d <- parse_design(design)
  k <- length(d$factors)
  if (is.null(levels)) {
    levels <- rep(2, k)
  }
  if (length(levels) != k) {
    stop("levels の長さを要因の数(", k, ")に合わせてください。")
  }
  names(levels) <- d$factors

  # 指定された効果を整理する
  flags <- list(A = A, B = B, C = C, AB = AB, AC = AC, BC = BC, ABC = ABC)
  sizes <- vapply(flags, effect_size, numeric(1), es = es)
  used <- names(sizes)[vapply(names(sizes), function(e) all(strsplit(e, "")[[1]] %in% d$factors), logical(1))]
  unused <- setdiff(names(sizes)[sizes != 0], used)
  if (length(unused) > 0) {
    stop("この design にない要因の効果が指定されています: ", paste(unused, collapse = ", "))
  }
  sizes <- sizes[used]

  # 1回分のデータをつくる
  generate <- function() {
    # 参加者と群間要因
    between_grid <- if (length(d$between) > 0) {
      expand.grid(lapply(levels[d$between], function(l) seq_len(l)))
    } else {
      data.frame(dummy = 1)
    }
    subjects <- between_grid[rep(seq_len(nrow(between_grid)), each = n), , drop = FALSE]
    subjects$id <- seq_len(nrow(subjects))
    subjects$u <- if (length(d$within) > 0) stats::rnorm(nrow(subjects), 0, sigma * sqrt(rho)) else 0

    # 群内要因(最後の要因がいちばん速く変わる順にする)
    within_grid <- if (length(d$within) > 0) {
      g <- expand.grid(rev(lapply(levels[d$within], function(l) seq_len(l))))
      g[, rev(names(g)), drop = FALSE]
    } else {
      data.frame(dummy2 = 1)
    }
    long <- merge(subjects, within_grid, by = NULL)
    long <- long[order(long$id), , drop = FALSE]

    # 効果を足し合わせる
    effect <- rep(0, nrow(long))
    for (e in names(sizes)) {
      if (sizes[e] == 0) next
      term <- rep(1, nrow(long))
      for (f in strsplit(e, "")[[1]]) {
        term <- term * level_scores(levels[f])[long[[f]]]
      }
      effect <- effect + sizes[e] * sigma / 2 * term
    }
    error_sd <- if (length(d$within) > 0) sigma * sqrt(1 - rho) else sigma
    long$value <- round(mu + effect + long$u + stats::rnorm(nrow(long), 0, error_sd), digits)

    # 要因を a1, a2, ... のラベルつきの因子にする
    for (f in d$factors) {
      long[[f]] <- factor(long[[f]], levels = seq_len(levels[f]), labels = paste0(tolower(f), seq_len(levels[f])))
    }
    long$id <- factor(long$id)
    long <- long[, c("id", d$between, d$within, "value"), drop = FALSE]
    rownames(long) <- NULL
    return(long)
  }

  # 乱数の種を決めて生成する(match のときは条件に合うまで種を変える)
  start <- if (is.null(seed)) 1 else seed
  if (!match) {
    if (!is.null(seed)) set.seed(seed)
    long <- generate()
    used_seed <- seed
  } else {
    found <- FALSE
    for (s in start:(start + max_try - 1)) {
      set.seed(s)
      long <- generate()
      attr(long, "design") <- design
      p <- anova_check(long)
      want <- sizes[names(p)] != 0
      if (all((p < alpha) == want)) {
        found <- TRUE
        used_seed <- s
        break
      }
    }
    if (!found) {
      stop("max_try 回試しても条件に合うデータが見つかりませんでした。n や es を大きくしてみてください。")
    }
  }

  attr(long, "design") <- design
  attr(long, "seed") <- used_seed
  if (format == "wide") {
    return(to_wide(long))
  }
  return(long)
}

# 横長(anovakun 用)にする ----------------------------------------------------------
# 群内要因の水準の組み合わせを列にする。列名は a1_b1 のようになる
to_wide <- function(long) {
  d <- parse_design(attr(long, "design"))
  if (length(d$within) == 0) {
    wide <- long
  } else {
    wide <- long %>%
      tidyr::pivot_wider(
        id_cols = dplyr::all_of(c("id", d$between)),
        names_from = dplyr::all_of(d$within),
        names_sep = "_",
        values_from = "value"
      ) %>%
      as.data.frame()
  }
  attr(wide, "design") <- attr(long, "design")
  attr(wide, "seed") <- attr(long, "seed")
  return(wide)
}

# 効果の確認 ----------------------------------------------------------------------
# aov で分散分析し，各効果の p 値を返す(球面性の補正はしない)
anova_check <- function(long) {
  d <- parse_design(attr(long, "design"))
  rhs <- paste(d$factors, collapse = " * ")
  if (length(d$within) > 0) {
    fml <- stats::as.formula(paste0("value ~ ", rhs, " + Error(id/(", paste(d$within, collapse = " * "), "))"))
  } else {
    fml <- stats::as.formula(paste0("value ~ ", rhs))
  }
  res <- summary(stats::aov(fml, data = long))
  tables <- if (inherits(res, "summary.aovlist")) res else list(res)
  p <- c()
  for (tb in tables) {
    t1 <- tb[[1]]
    rn <- trimws(rownames(t1))
    for (i in seq_along(rn)) {
      if (rn[i] == "Residuals") next
      p[gsub(":", "", rn[i])] <- t1[i, "Pr(>F)"]
    }
  }
  return(p)
}
