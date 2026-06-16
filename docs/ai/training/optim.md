## SGD
## SGD+momentum
## RMSProp
## Adam

计算当前梯度：$g_t = \nabla_\theta J(\theta_t)$

更新一阶矩（动量，估算梯度的期望）（$\beta_1$ 通常设为 0.9）：$$ m_t = \beta_1 \cdot m_{t-1} + (1 - \beta_1) \cdot g_t $$

更新二阶矩（梯度平方，估算梯度的未中心化方差）（$\beta_2$ 通常设为 0.999）：$$ v_t = \beta_2 \cdot v_{t-1} + (1 - \beta_2) \cdot g_t^2 $$

偏差修正（关键步）：因为 $m_0$ 和 $v_0$ 初始化为 0，在训练初期（$t$ 较小时），$m_t$ 和 $v_t$ 会严重偏向 0。为了消除这个人为初始化的影响，需要除以修正系数：
$$
\hat{m}_t = \frac{m_t}{1 - \beta_1^t} \\ \hat{v}_t = \frac{v_t}{1 - \beta_2^t} 
$$

(注：随着步数 $t$ 增大，$\beta^t$ 趋近于 0，修正系数趋近于 1，偏差修正便不再起作用)

更新参数：$$ \theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{\hat{v}_t} + \epsilon} \cdot \hat{m}_t $$