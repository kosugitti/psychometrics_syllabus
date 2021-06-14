my_lavaan_plot <- function(fit, standardized = TRUE) {
    require(lavaan)
    require(stringr)
    require(dplyr)
    require(DiagrammeR)
    
    #描画に必要なパラメータをdfとして取り出す
    pars <- parameterEstimates(fit,
                               standardized = standardized)
    # エッジ（パス）の設定、"=~"を抜き出しpaseteして因子負荷量
    temp01 <- dplyr::filter(pars, op == "=~")
    temp02 <- str_c('  \"', temp01$lhs,'\"', ' -> ','\"', temp01$rhs, '\"',
                    '[label=\"', round(temp01$std.all,2),
                    '\" color=blue penwidth=1.001];')
    # "~"を抜き出しpaseteして因子間回帰
    temp31 <- dplyr::filter(pars, op == "~")
    temp32 <- str_c('  \"', temp31$rhs,'\"', ' -> ','\"', temp31$lhs, '\"',
                    '[label=\"', round(temp31$std.all,2),
                    '\" color=black penwidth=1.001];')
    # "~~"抜き出す
    temp11 <- dplyr::filter(pars, op == "~~")
    temp12 <- str_c('  \"', temp11$rhs,'\"', ' -> ','\"', temp11$lhs, '\"',
                    '[label=\"', round(temp11$std.all,2),
                    '\" color=glay penwidth=1.001, dir = both];')
    # ノードの設定 観測変数と潜在因子
    temp00 <- inspect(fit)$lambda
    test.f <- colnames(temp00) #潜在因子
    test.v <- rownames(temp00) #観測変数
    temp21 <- str_c('  \"', test.f,'\" [fontname=\"Helvetica\" fontsize=14 fillcolor = green shape=ellipse style=filled];')
    temp22 <- str_c('  \"', test.v,'\" [fontname=\"Helvetica\" fontsize=14 fillcolor=\"transparent\" shape=box style=filled];')
    tempALL <- c('digraph \"res.s\" {',
                 '  layout = dot;', #dot, fdp
                 '  rankdir=LR;',
                 '  size=\"8,8\";',
                 temp21,
                 temp22,
                 temp02,
                 temp32,
                 '  center=1;',
                 temp12,
                 '}')
    
    grViz(tempALL)
}

source("https://raw.githubusercontent.com/onoshima/myfunction/master/lav2tikz.R")
source("https://raw.githubusercontent.com/onoshima/myfunction/master/lav2tikz_LR.R")

