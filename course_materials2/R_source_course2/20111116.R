### https://stackoverflow.com/questions/62551795/make-ggplot-with-regression-line-and-normal-distribution-overlay
library(ggplot2)
library(colorBlindness)
x <- seq(1, 11, 1)
y <- x * 0.5

x <- x - mean(x)
y <- y - mean(y)

df <- data.frame(x, y)

# For every row in `df`, compute a rotated normal density centered at `y` and shifted by `x`
curves <- lapply(seq_len(NROW(df)), function(i) {
  mu <- df$y[i]
  range <- mu + c(-3, 3)
  seq <- seq(range[1], range[2], length.out = 100)
  data.frame(
    x = -1 * dnorm(seq, mean = mu) + df$x[i],
    y = seq,
    grp = i
  )
})
# Combine above densities in one data.frame
curves <- do.call(rbind, curves)


ggplot(df, aes(x, y)) +
  geom_point() +
  geom_line() +
  # The path draws the curve
  geom_path(data = curves, aes(group = grp))




# 加工 ----------------------------------------------------------------------


dat <- read_csv("baseball2020.csv")
dataSet <- list(N = NROW(dat), Y = dat$height, X = dat$weight)
g <- dat %>% ggplot(aes(x = weight, y = height)) +
  geom_point() +
  geom_smooth(formula = "y~x", method = "lm", se = FALSE)

result.lm <- lm(height ~ weight, dat)

df2 <- data.frame(x = dat$weight, y = result.lm$fitted.values) %>%
  arrange(x)

dev <- 7
selection <- (NROW(df2) / dev) %>%
  round() %>%
  seq(1, NROW(df2), by = .)
selection <- c(selection, NROW(df2) - 15)
df2 <- df2[selection, ]

curves <- lapply(seq_len(NROW(df2)), function(i) {
  mu <- df2$y[i]
  range <- mu + c(-20, 20)
  seq <- seq(range[1], range[2], length.out = 100)
  data.frame(
    x = dnorm(seq, mean = mu, sd = 4.58) * 35 + df2$x[i],
    y = seq,
    grp = i
  )
})
# Combine above densities in one data.frame
curves <- do.call(rbind, curves)

g <- ggplot() +
  geom_point(data = dat, aes(x = weight, y = height), alpha = 0.3) +
  geom_smooth(
    data = dat, aes(x = weight, y = height),
    formula = "y~x", method = "lm", se = F, lwd = 2, color = palette()[4]
  ) +
  geom_path(data = curves, aes(x, y, group = grp), color = palette()[2], lwd = 1)

ggsave(g, filename = "../images/chapter24/Rplot24_06.png", dpi = 600, width = 8, height = 4)
g
