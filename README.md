# WeatherMap

>通过高德地图sdk，显示地图中城市的天气
>Show City Weather in Maps via Gaode Map SDK

1. 通过中国气象局的天气API，获取感兴趣的城市的天气
Request city weather in http://openweather.weather.com.cn

2. 根据获得天气的城市的名称，获取该城市的坐标轮廓
Then, request city outline in map
3. 将坐标轮廓显示在内置的高德地图中，并且填充颜色
And show the outline in the map and fill a color
4. 填充的颜色和当地的天气相对应，并且可以查询所有天气图例
A sepecific color mapping to a specific weather status, and you can check all the colors' meanings
5. 每个城市的中心位置（市中心）有一个图钉📌，可以查询具体天气
In the center of the interst citys, there is a spin that can be clicked to show detail weather info
6. 您可以选择多个感兴趣的省份，显示这些省份的城市的天气
You can select many provinces, can this app can show weather for all the cities in these provinces
7. 现在，可以查询天气，气温和风力信息
Now, you can check weather, tempetature and wind info
