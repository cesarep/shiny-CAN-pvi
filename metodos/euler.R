X = x0; Y = y0
dYdX = dydx(x0, y0)
for(i in 1:N){
   X[i+1] = X[i] + h
   Y[i+1] = Y[i] + h*dYdX[i]
   dYdX[i+1] = dydx(X[i+1], Y[i+1])
}
tabela <- cbind(i = 0:N, X, Y, dYdX)
cab = c("i", 'x_i', 'y_i', '\\frac{dy}{dx}')