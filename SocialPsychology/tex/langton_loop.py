import numpy as np
import matplotlib.pyplot as plt
from matplotlib import colors
from matplotlib import animation
import os

class LangtonLoop:
    def __init__(self, size=50):
        self.size = size
        self.grid = np.zeros((size, size), dtype=int)
        self.initialize_rules()
        self.setup_initial_pattern()
        
    def initialize_rules(self):
        # Langtonループの遷移ルール
        self.rules = {
            # ルール形式: (Center, North, East, South, West) -> New State
            
            # Core (状態2) のメンテナンス
            (2,0,2,0,2): 2,
            (2,2,0,2,0): 2,
            (2,2,2,0,0): 2,
            
            # Sheath (状態1) のメンテナンス
            (1,0,1,0,1): 1,
            (1,1,0,1,0): 1,
            (1,1,1,0,0): 1,
            
            # シグナル伝播 (状態3-7)
            (0,2,3,0,0): 4,
            (0,2,4,0,0): 5,
            (0,2,5,0,0): 6,
            (0,2,6,0,0): 7,
            (0,2,7,0,0): 3,
            
            # 構築ルール
            (0,1,3,0,0): 1,
            (1,1,4,0,0): 2,
            (0,2,5,1,0): 1,
        }

    def setup_initial_pattern(self):
        # 初期パターンの設定
        center = self.size // 2
        pattern = np.array([
            [1,1,1,1,1,1,1],
            [1,2,2,2,2,2,1],
            [1,2,0,0,0,2,1],
            [1,2,0,3,0,2,1],
            [1,2,0,0,0,2,1],
            [1,2,2,2,2,2,1],
            [1,1,1,1,1,1,1]
        ])
        
        r, c = pattern.shape
        start_r = center - r//2
        start_c = center - c//2
        self.grid[start_r:start_r+r, start_c:start_c+c] = pattern

    def get_von_neumann_neighborhood(self, r, c):
        # フォン・ノイマン近傍の取得
        return (
            self.grid[r,c],     # Center
            self.grid[r-1,c],   # North
            self.grid[r,c+1],   # East
            self.grid[r+1,c],   # South
            self.grid[r,c-1]    # West
        )

    def step(self):
        # 1ステップの更新
        new_grid = self.grid.copy()
        
        for r in range(1, self.size-1):
            for c in range(1, self.size-1):
                neighborhood = self.get_von_neumann_neighborhood(r, c)
                if neighborhood in self.rules:
                    new_grid[r,c] = self.rules[neighborhood]
        
        self.grid = new_grid
        return self.grid

    def save_generation(self, gen_number):
        # 世代の状態を画像として保存
        cmap = colors.ListedColormap(['white', 'gray', 'blue', 
                                    'red', 'green', 'yellow', 
                                    'magenta', 'orange'])
        
        plt.figure(figsize=(10, 10))
        plt.imshow(self.grid, cmap=cmap, vmin=0, vmax=7)
        plt.grid(True, which='both', color='lightgrey', linewidth=0.5)
        plt.title(f'Generation {gen_number}')
        
        # 保存ディレクトリの作成
        os.makedirs('langton_output', exist_ok=True)
        plt.savefig(f'langton_output/gen_{gen_number:04d}.png')
        plt.close()

def run_simulation(generations=200, save_interval=10, size=50):
    # シミュレーションの実行
    loop = LangtonLoop(size)
    
    for gen in range(generations):
        if gen % save_interval == 0:
            loop.save_generation(gen)
        loop.step()
    
    # 最終世代を保存
    loop.save_generation(generations)

if __name__ == "__main__":
    run_simulation(200, 10, 50)