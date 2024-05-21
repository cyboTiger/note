投标问题第三问：
已知部分人使用数学建模方法优化自己的策略，如何应对

1. 假设该部分人使用均匀/正态分布预估他人出价，那么可以预测出他们针对这些预估理论给出的出价，然后以此作为我们的出价
2. 假设该部分人预测对方。采取使得对方采取行动时，收益最大的行动的收益值最小



3. 假设一开始所有人的价格都随机(or whatever)，然后那一部分使用建模优化策略的人使用如下的策略，假设招标人意向价格为A固定，则他们执行如下的算法，每个人计算出当前的基准价后，将自己的价格设为基准价；最后直到基准价收敛到一定程度时停止，该基准价即为那一部分优化者的报价

但我们容易发现，在 3. 的情况下，那一部分优化者所有人最终都会收敛于招标人意向价作为自己的出价，那么此时就无法区分出彼此了，也即都不能中标。因此，该部分人不会单纯采取此迭代策略，此时

+ 我们可以改善该策略的**区分度**，通过模拟退火算法、贪心/探索概率算法，避免所有人都聚集于某个单一价位。其中，模拟退火算法的温度可以由所有人的当前出价聚集稠密度（这个再琢磨一下怎么设计公式）来决定，若出价越聚集在小范围内，则温度越高，即当前优化者不选择当前计算出的基准价的概率越大。既然不选择计算出的基准价，那么至于如何更新自己的出价，由于我们希望最终结果趋于稳定，又不聚集在招标人意向价附近，所以可以设置为**随机用其他10组(A,B1,B2)的任意一组替换当前(A,B1,B2)来计算得到的基准价**。

可以证明，在此策略下，最终各位的出价是趋于稳定的分散分布的，证明如下：
!!! info "Proof of convergence"
    我们的迭代公式为

    $$
    A_{new1} =Base_1(A_{new0},(A,B_1,B_2))*concentration + Base_0(A_0,(A,B_1,B_2))*(1-concentration)
    $$

    其中$Base_1,Base_0$为更换参数组合$(A,B_1,B_2)$前后，计算评标基准价的函数；这是一个数学期望的表达式

    可以看到， $A_{new1}$ 有 $1-concentration$ 的概率取值 $Base_0(A_{new0},(A,B_1,B_2))$ 。我们希望$A_{new1}$在$concentration$小时，即在$A_{new1}$ 取值 $Base_0(A_0,(A,B_1,B_2))$ 时能够在迭代中逐渐收敛，而这个公式恰好可以保证这一性质。

    为证明结论成立，我们比较前一次和后一次迭代过程中出价的变化值
    $$
    A_{new1} = Base_0(A_{new0},(A,B_1,B_2))
    $$
    根据收敛的假设，除$A_0$外其他人出价已经达到收敛值，因此变化可忽略。那么有
    $$
    A_{new2} = Base_0(A_{new1},(A,B_1,B_2))
    $$
    于是，比较两次更新出价造成的出价变化

    $$
    A_{new2}-A_{new1} \\
    =(\frac{A_1+A_2+...+A_{new1}+...+A_n}{n}\times B_1 + A_{second-low}\times B_2 + A\times (1-B_1-B_2))\\
    -(\frac{A_1+A_2+...+A_{new0}+...+A_n}{n}\times B_1 + A_{second-low}\times B_2 + A\times (1-B_1-B_2))\\
    = \frac{B_1}{n}\times (A_{new1}-A_{new0}) < A_{new1}-A_{new0}
    $$
    
    证毕

这样，可以模拟11种组合等概率的场景，同时可以猜测，最终的结果可能是在各个意向价都聚集若干（远少于总人数n）的投标人，这就达到了我们避免所有人聚集在某区间的问题

具体代码如下
??? code "code"
    ``` python title="simulated_anneal.py" linenums="1"
    import random
    import math
    import numpy as np

    def compute_base_price(prices, a, b1, b2):
        copy_prices = [price for price in prices]
        copy_prices.sort()
        return sum(copy_prices) / len(copy_prices) * b1 + copy_prices[1] * b2 + a * (1 - b1 - b2)
    def raw_iteration(prices, a, b1, b2, error):
        diff = error + 1
        i = 0
        while diff > error:
            prices[i] = compute_base_price(prices, a, b1, b2)
            diff_list = [abs(price - compute_base_price(prices, a, b1, b2)) for price in prices]
            diff = max(diff_list)
            i = (i + 1) % len(prices)
        return prices

    def cluster_size(prices, cluster_range, starting_price):
        # return (size, next_price)
        copy_prices = [price for price in prices]
        copy_prices.sort()
        starting_idx = copy_prices.index(starting_price)
        cur_idx = starting_idx + 1
        last_idx = starting_idx
        while cur_idx < len(copy_prices):
            if copy_prices[cur_idx] - copy_prices[last_idx] < cluster_range:
                last_idx = cur_idx
                cur_idx += 1
            else:
                break
        if cur_idx == len(copy_prices):
            return (last_idx - starting_idx + 1, None)
        return (last_idx - starting_idx + 1, copy_prices[cur_idx])

    def divide_by_cluster(prices, cluster_range):
        # return (cluster_num, max_cluster_size)
        cluster_num = 0
        max_size = 0
        first_price = min(prices)
        cur_price = first_price
        val = cluster_size(prices, cluster_range, cur_price)
        cluster_num += 1
        while val[1]:
            if max_size < val[0]:
                max_size = val[0]
            cur_price = val[1]
            val = cluster_size(prices, cluster_range, cur_price)
            cluster_num += 1
        if max_size < val[0]:
                max_size = val[0]
        return (cluster_num, max_size)
        
    def concentration(prices, cluster_range):
        w1 = 0.3
        w2 = 0.7
        min_val = 2 * math.sqrt(w1 * w2 / len(prices))
        max_val = w2 + w1 / len(prices)
        (cluster_num, max_size) = divide_by_cluster(prices, cluster_range)
        val = w1 * cluster_num / len(prices) + w2 * max_size / len(prices)
        return (val - min_val) / (max_val - min_val)
        # range from 0 to 1
        # w1 * cluster_num / n + w2 * max_cluster_size / n
        # >= 2 * sqrt(w1 * w2 * cluster_num * max_cluster_size / n**2)
        # >= 2 * sqrt(w1 * w2 / n)
        # <= w2
    def random_choose_A_B1_B2(A,B1,B2,a,b1,b2):
        i = random.randrange(0,11)
        while (A[i],B1[i],B2[i]) == (a,b1,b2):
            i = random.randrange(0,11)
        return (A[i],B1[i],B2[i])
    def simulated_annealing_iteration(prices, a, b1, b2, error, max_iteration, cluster_range=10000):
        diff = error + 1
        i = 0
        cnt = 0
        concentration_deg = concentration(prices, cluster_range)
        while (diff > error  or concentration_deg > 0.5) and cnt <= max_iteration:
            base_price1 = compute_base_price(prices, a, b1, b2)
            (a_rand, b1_rand, b2_rand) = random_choose_A_B1_B2(A,B1,B2,a,b1,b2)
            base_price2 = compute_base_price(prices, a_rand, b1_rand, b2_rand)
            val = int(np.random.binomial(n=1, p=concentration_deg, size=1)[0])
            temp = prices[i]
            prices[i] = val * base_price2 + (1 - val) * base_price1
            diff = abs(temp - prices[i])
            i = (i + 1) % len(prices)
            cnt += 1
            concentration_deg = concentration(prices, cluster_range)
        return prices
    A_max = 4907459 
    A_min = 4649516
    A = [4642976, 4668770.3, 4694564.6, 4720358.9, 4746153.2, 
        4771947.5, 4797741.8, 4823536.1, 4849330.4, 4875124.7, 4900919]
    B1 = [0.15, 0.16, 0.17, 0.18 , 0.19 ,
        0.20 , 0.21 , 0.22 , 0.23 , 0.24 ,0.25]
    B2 = B1


    n = int(input("n: "))
    k = int(input("How many persons use strategy: "))

    strategy_bidders = []
    row_bidders = []
    # initialize everyone's offer randomly
    strategy_bidders = [random.randrange(A_min, A_max) for i in range(k)]
    raw_bidders = [random.randrange(A_min, A_max) for i in range(n-k)]

    # randomly choose 3th (A,B1,B2),
    # and set error <= 1000
    # and set max_iteration_cycle = 10000
    simulated_annealing_iteration(strategy_bidders, A[3], B1[3], B2[3], \
                                1000, 10000)

    final_ans = strategy_bidders + row_bidders 
    # get the final price distribution of all bidders
    # except ourselves
    # next we can simply apply 
    # compute_base_price(final_ans, A[rand], B1[rand], B2[rand])
    # to get our ideal price
    ```
