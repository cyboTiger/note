## 位姿描述
在一个坐标系中，一个物体的描述由位置和姿态组成；对于位置，用xyz三维坐标表示；对于姿态，则使用3x3的旋转矩阵来表示物体的三个朝向与参考坐标系三个轴之间的夹角

### 位置矢量
以A坐标系为参考坐标系，点B的位置矢量：

$$
{}^A_BP=
\begin{bmatrix}
x^B \\
y^B \\
z^B
\end{bmatrix}
$$

### 旋转矩阵
以点P为原点建立坐标系，该坐标系{P}的三个轴相对于参考坐标系{A}三个轴的共九个角度的余弦值，组成一个3x3的矩阵，该矩阵就是旋转矩阵，因该矩阵是{P}相对于{A}的姿态关系的表示，故记作 $ {}^A_P R $

$$
{}^A_P R=[{}^Ax_P, {}^Ay_P, {}^Az_P]=
\begin{bmatrix}
P_x \cdot A_x & P_y \cdot A_x & P_z \cdot A_x \\
P_x \cdot A_y & P_y \cdot A_y & P_z \cdot A_y \\
P_x \cdot A_z & P_y \cdot A_z & P_z \cdot A_z 
\end{bmatrix}
$$

转置矩阵即为坐标系A相对于坐标系P的姿态：

$$
{}^A_P R^T={}^P_A R={}^A_P R^{-1}=
\begin{bmatrix}
P_x \cdot A_x & P_x \cdot A_y & P_x \cdot A_z \\
P_y \cdot A_x & P_y \cdot A_y & P_y \cdot A_z \\
P_z \cdot A_x & P_z \cdot A_y & P_z \cdot A_z 
\end{bmatrix}
$$

### 平移旋转复合变换
一般情况下两个坐标系原点不重合姿态也不相同。我们将坐标变换拆分成先绕参考坐标系旋转（A到B），再绕参考坐标系平移两步（B到C），这样我们就得到了坐标的复合变换方程：

$$
{}^A_CP={}^A_BR{}^B_CP+{}^A_BP
$$

### xyz轴指向规定
按照右手法则

## 姿态的多种表示

三类共五种方法如下：

+ 旋转矩阵：旋转矩阵
+ 坐标轴旋转：固定轴欧拉角、非固定轴欧拉角
+ 任意轴旋转：等效轴角、四元数

### 旋转矩阵
绕某一轴旋转 $\theta$ 角的旋转矩阵

$$
\textbf{x\ axis}:\ 
\begin{bmatrix}
1 & 0 & 0 \\
0 & \cos\theta & -\sin\theta \\
0 & \sin\theta & \cos\theta 
\end{bmatrix}
$$

$$
\textbf{y\ axis}:\ 
\begin{bmatrix}
\cos\theta & 0 & -\sin\theta \\
0 & 1 & 0 \\
-\sin\theta & 0 & \cos\theta 
\end{bmatrix}
$$

$$
\textbf{z\ axis}:\ 
\begin{bmatrix}
\cos\theta & -\sin\theta & 0 \\
\sin\theta & \cos\theta & 0 \\
0 & 0 & 1 
\end{bmatrix}
$$

### 欧拉角
旋转矩阵需要3x3=9个数来表示旋转，存在冗余。考虑从一个坐标系按x/y/z轴旋转到另一个坐标系，旋转3次即可实现任意的旋转
#### 参考固定坐标系
首先我们来考虑绕固定的坐标系旋转如何转换成旋转矩阵，我们以XYZ的旋转顺序来举例说明，其他旋转顺序类似

现在假设A、B两个坐标系重合，B坐标系绕A坐标系的X轴旋转45度，绕A的Z轴旋转90度。求旋转之后，以A为参考坐标系，B坐标系的姿态

$$
{}^A_B R_{XYZ(45,0,90)}
$$

解：我们可以假设一个向量v固定在B坐标系上，那我们让B坐标系绕着A坐标系的三个轴做旋转，就可以认为是让向量v绕着坐标系A的三个轴做旋转，那先转的肯定先乘，所以我们先让向量 $v$ 乘上 $R_{X(45)}$，再让其乘上 $R_{Z(90)}$，即： 

$$
v'=R_{Z(90)}(R_{X(45)}v)
$$

$v'$ 就是旋转后的 $v$ 向量在A坐标系中的位置矢量

所以我们可以得到，绕固定轴XYZ旋转的欧拉角转旋转矩阵方法: 

$$
R_{XYZ(\gamma,\beta,\alpha)}=R_{Z(\alpha)}R_{Y(\beta)}R_{X(\gamma)}
$$

$$
\begin{bmatrix}
c\alpha c\beta & c\alpha s\beta s\gamma-s\alpha c\gamma & c\alpha s\beta c\gamma+s\alpha s\gamma \\
s\alpha c\beta & s\alpha s\beta s\gamma + c\alpha c\gamma & s\alpha s\beta c\gamma - c\alpha s\gamma \\
-s\beta & c\beta s\gamma & c\beta c\gamma 
\end{bmatrix}
$$

#### 参考自身坐标系
因为每次都是绕自身旋转（A到B'到B''到B），所以可以拆解为：

$$
{}^A_BR={}^A_{B'}R{}^{B'}_{B''}R{}^{B''}_BR
$$

如果按照Z-Y-X的顺序旋转，则可以得到：

$$
{}^A_BR_{Z'Y'X'}=R_{Z(\alpha)}R_{Y(\beta)}R_{X(\gamma)}
$$

### 轴角
