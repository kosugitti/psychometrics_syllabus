library(ggplot2)
library(tidyr)

# グリッドサイズの設定
grid_size <- 20
grid <- matrix(0, nrow = grid_size, ncol = grid_size)

# 初期のラングトンのループ
grid[10, 10:13] <- 1  # シェル（外壁）
grid[11, 10] <- 1
grid[11, 13] <- 1
grid[12, 11:12] <- 3  # 信号経路
grid[11, 11] <- 2     # 信号

# 更新ルールの実装
update_grid <- function(grid) {
  new_grid <- grid  # グリッドのコピー
  
  for (x in 1:nrow(grid)) {
    for (y in 1:ncol(grid)) {
      state <- grid[x, y]
      
      if (state == 2) {  # 信号の移動と拡張
        # 上下左右に信号を伝播
        if (x > 1 && grid[x-1, y] == 3) new_grid[x-1, y] <- 2  # 上
        if (x < nrow(grid) && grid[x+1, y] == 3) new_grid[x+1, y] <- 2  # 下
        if (y > 1 && grid[x, y-1] == 3) new_grid[x, y-1] <- 2  # 左
        if (y < ncol(grid) && grid[x, y+1] == 3) new_grid[x, y+1] <- 2  # 右
        
        # 新しいシェルを作成（空セルが隣接している場合）
        if (x > 1 && grid[x-1, y] == 0) new_grid[x-1, y] <- 1
        if (x < nrow(grid) && grid[x+1, y] == 0) new_grid[x+1, y] <- 1
        if (y > 1 && grid[x, y-1] == 0) new_grid[x, y-1] <- 1
        if (y < ncol(grid) && grid[x, y+1] == 0) new_grid[x, y+1] <- 1
        
        # 信号が通過したセルは経路に戻す
        new_grid[x, y] <- 3
      }
    }
  }
  return(new_grid)
}

# グリッドをデータフレームに変換
grid_to_df <- function(grid) {
  as.data.frame(grid) %>%
    mutate(Row = row_number()) %>%
    pivot_longer(-Row, names_to = "Column", values_to = "value") %>%
    mutate(Column = as.numeric(gsub("V", "", Column)))
}

# 出力フォルダの作成
output_folder <- "langton_loop_images"
dir.create(output_folder, showWarnings = FALSE)

# シミュレーションの実行
for (t in 1:50) {
  grid <- update_grid(grid)  # グリッドの更新
  
  # 10ターンごとに画像を保存
  if (t %% 10 == 0) {
    grid_df <- grid_to_df(grid)
    
    p <- ggplot(grid_df, aes(x = Column, y = Row, fill = factor(value))) +
      geom_tile(color = "white") +
      scale_fill_manual(values = c("white", "black", "red", "blue"), 
                        labels = c("空", "シェル", "信号", "経路")) +
      theme_minimal() +
      labs(title = paste("Turn:", t), fill = "State") +
      theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())
    
    ggsave(sprintf("%s/langton_turn_%03d.png", output_folder, t), 
           plot = p, width = 6, height = 6)
  }
}
