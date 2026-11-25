# 図23.6「平均と標準偏差による2変数関数としての正規分布の尤度(上)と対数尤度(下)」を描く
# データは本文の身長 165, 173, 182。最尤推定値(平均 173.3・標準偏差 6.94)が図の中に入るよう，
# 標準偏差は 5〜15 の範囲で描く(旧図は 12〜22 で，山の頂上が図の外にあった・2026-11-25)

# データと対数尤度 ------------------------------------------------------------
x <- c(165, 173, 182)
loglik <- function(mu, sigma) {
  return(sum(stats::dnorm(x, mean = mu, sd = sigma, log = TRUE)))
}

# 格子 ------------------------------------------------------------------------
mu <- seq(160, 186, length.out = 40)
sigma <- seq(5, 15, length.out = 40)
LL <- outer(mu, sigma, Vectorize(loglik))

# 最尤推定値(標準偏差は n で割る) ---------------------------------------------
mu_hat <- mean(x)
sigma_hat <- sqrt(mean((x - mu_hat)^2))
ll_hat <- loglik(mu_hat, sigma_hat)

# 描画 ------------------------------------------------------------------------
# 同じ格子・同じ向きで，縦軸を尤度にした図と対数尤度にした図を1枚ずつ書く。赤い点が最尤推定値
draw_surface <- function(file, z, z_hat, zlab) {
  grDevices::png(file, width = 560, height = 490)
  graphics::par(mar = c(1, 1, 1, 1))
  pm <- graphics::persp(
    mu, sigma, z,
    theta = -35, phi = 25, expand = 0.8,
    col = "lightblue", border = "grey40", shade = 0.3,
    ticktype = "detailed", cex.axis = 0.8,
    xlab = "mu", ylab = "sigma", zlab = zlab
  )
  graphics::points(grDevices::trans3d(mu_hat, sigma_hat, z_hat, pm), col = "red", pch = 19, cex = 2)
  grDevices::dev.off()
  return(invisible(file))
}

draw_surface("lik_norm2.png", exp(LL), exp(ll_hat), "likelihood")
draw_surface("loglik_norm2.png", LL, ll_hat, "log-likelihood")
