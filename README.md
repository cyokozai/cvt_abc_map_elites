# ABC MAP-Elites

## 品質多様性アルゴリズム ABC MAP-Elitesについて

実世界の問題では優良解が実装不可能な場合や，計測値にノイズが存在する場合がある．  
それゆえ，最適解と同時に多様な準最適解を探索する，品質多様性アルゴリズムが提案されている．  
既存手法では，品質多様性アルゴリズムのひとつである MAP-Elites[^1] の探索フェーズに差分進化 (Differential Evolution | DE)[^2] を用いた Differential MAP-Elites (DME)[^3] が提案された．  
探索性能が向上した一方，差分進化のパラメータ依存性や局所最適解からの脱出能力の低さが指摘されている．  
そこで，パラメータ調整が容易かつ局所最適解からの脱出能力が高い，Artificial Bee Colony Argorithm (ABC)[^4] に着目する．  
本研究では，ノイズ耐性を持つ品質多様性探索を行うため，ABC と MAP-Elites を組み合わせた ABC MAP-Elites (ABCME) を提案し，その有効性を検証する．

[^1]: Illuminating search spaces by mapping elites <http://arxiv.org/abs/1504.04909>
[^2]: Differential Evolution - A Simple and Efficient Heuristic for Global Optimization over Continuous Spaces <https://doi.org/10.1023/A:1008202821328>
[^3]: Self-referential quality diversity through differential MAP-Elites <https://doi.org/10.1145/3449639.3459383>
[^4]: An Idea Based on Honey Bee Swarm for Numerical Optimization, Technical Report - TR06 <https://abc.erciyes.edu.tr/pub/tr06_2005.pdf>

## How to use this program

### Install

- Docker

    ```shell
    make container
    ```

- Local

    ```shell
    make local-run
    ```

- All

    ```shell
    make all
    ```

- Confirm apps

    ```shell
    $ docker -v
    Docker version 27.3.1, build ce12230
    $ julia -v
    julia version 1.10.5
    $ python3 -V
    Python 3.10.12
    $ pip -V
    pip 22.0.2 from /usr/lib/python3/dist-packages/pip (python 3.10)
    ```

### Deploy the programs on Docker

- Set the source code into `./src`
- Test `./docker-runner.py`

    ```shell
    python3 docker-runner.py test
    ```

- Run `./docker-runner.py`

    ```shell
    python3 docker-runner.py
    ```

### MAP-elites Configuration

- Open `./src/config.jl`

---

### General Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `D`                            | 次元数                                                              | `ARGS[1]`         | `ARGS[1] == "test"`の場合は2に固定    |
| `N`                            | 集団サイズ                                                          | 64                 |                                       |
| `BD`                           | 行動次元数                                                          | 2                  | 変更不可                             |
| `CONV_FLAG`                    | 収束フラグ                                                          | `false`            | `true`の場合、収束確認モード         |
| `EPS`                          | 収束判定の閾値                                                      | `1e-6`             |                                       |
| `FIT_NOISE`                    | フィットネスにノイズを追加するか                                    | `true`             |                                       |
| `r_noise`                      | ノイズ率                                                            | `0.01`             |                                       |
| `MAXTIME`                      | 最大時間ステップ数                                                  | 条件により変化     | `CONV_FLAG`や`OBJ_F`に依存           |

---

### MAP Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `GRID_SIZE`                    | グリッドマップのグリッドサイズ                                      | `158`              | `MAP_METHOD == grid`時に使用         |
| `k_max`                        | CVT方式の最大クラスタ数                                             | `25000`            | `MAP_METHOD == cvt`時に使用          |

---

### Voronoi Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `cvt_vorn_data_update_limit`   | Voronoiデータの更新制限                                             | `3`                | `ARGS[5]`で指定可能                  |
| `CVT_MAX_ITER`                 | CVTの最大反復回数                                                   | `100`              |                                       |

---

### MAP-Elites Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `MUTANT_R`                     | 突然変異率                                                          | `0.90`             |                                       |

---

### Differential MAP-Elites Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `CR`           | 交叉確率。目的関数によって値が変化する。                                   | 条件により変化     | `OBJ_F`に依存                        |
| `F`            | 差分（突然変異）スケーリング係数。目的関数によって値が変化する。                      | 条件により変化     | `OBJ_F`に依存                        |

#### 目的関数ごとの`CR`と`F`

| 目的関数           | `CR`   | `F`   |
|-------------------|--------|-------|
| `sphere`          | `0.10` | `0.30` |
| `rosenbrock`      | `0.75` | `0.70` |
| `rastrigin`       | `0.01` | `0.50` |
| `griewank`        | `0.20` | `0.50` |
| `ackley`          | `0.20` | `0.50` |
| `schwefel`        | `0.20` | `0.50` |
| `michalewicz`     | `0.20` | `0.50` |
| その他             | `0.8`  | `0.9`  |

---

### ABC MAP-Elites Parameters

| パラメータ名                    | 説明                                                                 | デフォルト値       | 備考                                  |
|--------------------------------|----------------------------------------------------------------------|--------------------|---------------------------------------|
| `FOOD_SOURCE`                  | ABCの食料源（探索限界トライアル数）                                 | `N`                |                                       |
| `TC_LIMIT`                     | ABCの探索限界トライアル数                                           | `D * floor(Int, k_max / (10 * FOOD_SOURCE))` | |

---

## Graphs and plots

### Make the convergence graphs and vorn plot in PDF

- Check the file name of the result data in `./src/result`
- Compose up `./docker-compose.yaml`

    ```shell
    docker compose  -f "docker-compose.yaml" up -d --build julia-figure
    ```

- ~~Run `./make=plot.py` & `./make-vorn.py`~~
  - Unavailable

    ```shell
    julia make-plot.jl <Dimention> <Method> <Grid or CVT> <Objective function> <Fitness or CVT>
    ```

### Plots Configuration

- Open `./src/make-plot.jl`

### Sample graphs

- `fitness-testdata.pdf`

![sample-fitness](./result/testdata/fitness-testdata.pdf)

- `behavior-testdata.pdf`

![sample-behavior](./result/testdata/behavior-testdata.pdf)
