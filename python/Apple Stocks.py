#!/usr/bin/env python
# coding: utf-8

# In[1]:


import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


# In[20]:


apple_stock = yf.download('AAPL', start = '2022-01-01', end = '2023-01-01')


# In[3]:


apple_stock.head()


# In[21]:


apple_stock['Daily_Return'] = apple_stock['Adj Close'].pct_change()
apple_stock.head()


# In[22]:


plt.plot(apple_stock['Daily_Return'])
plt.title('Apple Daily Returns')
plt.xlabel('Date')
plt.xticks(rotation = 75)
plt.ylabel('Daily Return')
plt.show()


# In[26]:


#50days moving average
apple_stock['50_MA'] = apple_stock['Adj Close'].rolling(window = 50).mean()


# In[24]:


apple_stock.tail(10)


# In[27]:


plt.plot(apple_stock['Adj Close'], label = 'Adj Close')
plt.plot(apple_stock['50_MA'], label = '50-day MA')
plt.title('Apple Stock Price and 50-Day Moving Average')
plt.xlabel('Date')
plt.xticks(rotation = 75)
plt.ylabel('Price($)')
plt.legend()
plt.show()


# In[30]:


volatility  = apple_stock['Daily_Return'].std()
print(f'Volatility : {volatility}')


# In[33]:


risk_free_rate = 0.01 
annual_return =(apple_stock['Daily_Return'].mean()+1)**252-1
annual_volatility = apple_stock['Daily_Return'].std()*np.sqrt(252) #we are only working on weekdays not weekends 
sharpe_ratio = (annual_return - risk_free_rate)/annual_volatility 
print(f'Sharpe Ratio: {sharpe_ratio}')

# movement of the trend is downward so we got negative sharpe ratio


# In[34]:


sp500 = yf.download("^GSPC", start = '2022-01-01', end = '2023-01-01')


# In[35]:


sp500.head()


# In[37]:


sp500['Daily_Return_SP500'] = sp500['Adj Close'].pct_change()
sp500


# In[39]:


joined_data = pd.concat([apple_stock['Daily_Return'],sp500['Daily_Return_SP500']], axis =1).dropna()


# In[40]:


joined_data.head()


# In[42]:


beta = joined_data.cov().iloc[0,1]/joined_data['Daily_Return_SP500'].var()


# In[44]:


print(f'Beta : {beta}')


# In[46]:


apple_stock['20_MA'] = apple_stock['Adj Close'].rolling(window = 20).mean()


# In[47]:


apple_stock['Upper_Band'] = apple_stock['20_MA']+2*apple_stock['Adj Close'].rolling(window = 20).std()


# In[51]:


apple_stock.iloc[20:]


# In[52]:


apple_stock['Lower_Band'] = apple_stock['20_MA']-2*apple_stock['Adj Close'].rolling(window = 20).std()


# In[54]:


apple_stock.tail()


# In[56]:


plt.plot(apple_stock['Adj Close'], label ='Adj Close')
plt.plot(apple_stock['20_MA'], label = '20-day MA')
plt.plot(apple_stock['Upper_Band'], label = 'Upper Band')
plt.plot(apple_stock['Lower_Band'], label = 'Lower Band')
plt.title('Apple Stock Price and Bollinger Bands')
plt.xlabel('Date')
plt.ylabel('Price ($)')
plt.legend()
plt.show()


# In[74]:


delta = apple_stock['Adj Close'].diff(1)
gain = (delta.where(delta >0,0)).rolling(window=14).mean()
loss = (-delta.where(delta<0,0)).rolling(window =14).mean()


# In[75]:


rs = gain/loss


# In[76]:


apple_stock['RSI'] = 100-(100/(1+rs))


# In[77]:


apple_stock['RSI']


# In[78]:


plt.plot(apple_stock['RSI'])
plt.title('Apple Stock Relative Strength Index (RSI)')
plt.xlabel('Date')
plt.ylabel('RSI')
plt.show()

