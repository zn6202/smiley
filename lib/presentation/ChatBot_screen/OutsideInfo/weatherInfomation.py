import requests
import json
from collections import defaultdict
import os

# 取出API
api_auth = os.getenv('WEATHER_API')

# 中央氣象署開放資料平臺之資料擷取API
# https://opendata.cwa.gov.tw/dist/opendata-swagger.html#/
# 回傳天氣資訊
def WeatherForcast():
    # 一、取得ㄧ般天氣預報-今明36小時天氣預報
    url = f'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization={api_auth}'
    data = requests.get(url)
    if data.status_code == 200:
        data_json = data.json()
        dataset_description = data_json['records']['datasetDescription']
        locations = data_json['records']['location']
        # print(f"資料集描述: {dataset_description}、臺灣各縣市天氣預報資料及國際都市天氣預報")
        
        # 整合各項預報因子資訊為description
        for location in locations:
            # 縣市名
            location_name = location['locationName']
            # print(location_name)
            # 每個縣市的各種預報因子
            weather_elements = location['weatherElement']
            # print(f"地區: {location_name}")
            # 預報因子、時間範圍
            for element in weather_elements:
                element_name = element['elementName']
                times = element['time']
                # 預報因子：Wx天氣現象,ManT最高溫度,MinT最低溫度,CI舒適度,PoP降雨機率
                # print(f"  預報因子: {element_name}")
                for time in times:
                    start_time = time['startTime']
                    end_time = time['endTime']
                    parameter = time['parameter']
                    description = ""
                    match(element_name):
                        case "Wx":
                            parameter_name = parameter['parameterName']
                            parameter_value = parameter['parameterValue']
                            parameter['description'] = f"天氣狀況為：{parameter_name}"
                        case "PoP":
                            parameter_name = parameter['parameterName']
                            parameter_unit = parameter['parameterUnit']
                            parameter['description']  = f"降雨機率：{parameter_name}%"
                        case "MinT":
                            parameter_name = parameter['parameterName']
                            parameter_unit = parameter['parameterUnit']
                            parameter['description']  = f"最低溫度：{parameter_name}°C"
                        case "CI":
                            parameter_name = parameter['parameterName']
                            parameter['description'] = f"舒適度：{parameter_name}"
                        case "MaxT":
                            parameter_name = parameter['parameterName']
                            parameter_unit = parameter['parameterUnit']
                            parameter['description'] = f"最高溫度：{parameter_name}°C"

        # 二、標準化同個時間範圍的資訊
        dataset_description = data_json['records']['datasetDescription']
        locations = data_json['records']['location']
        for location in locations:
            location_name = location['locationName']
            weather_elements = location['weatherElement']

            # 使用 defaultdict 來合併相同 startTime 的描述
            time_dict = defaultdict(list)

            for element in weather_elements:
                times = element['time']
                # 合併相同 startTime 的資料
                for time in times:
                    start_time = time['startTime']
                    end_time = time['endTime']
                    parameter = time['parameter']
                    description = time['parameter']['description']
                    # 合併描述
                    time_dict[(start_time, end_time)].append(description)

            # 清空原有的 weatherElement
            location['weatherElement'] = []
            # 將合併後的描述添加回去
            for (start_time, end_time), descriptions in time_dict.items():
                merged_description = "、".join(descriptions)
                start_time = start_time.replace(" ", "的")
                end_time = end_time.replace(" ", "的")
                location['weatherElement'].append({
                    "time": [
                        {
                            "startTime": start_time,
                            "endTime": end_time,
                            "description": merged_description
                        }
                    ]
                })
        # json_data_final = json.dumps(data_json, ensure_ascii=False, indent=2)
        # print(json_data_final)

        # 三、重組字典結構
        new_data_structure = {
            "datasetDescription": f"{data_json['records']['datasetDescription']}，臺灣各縣市天氣預報資料及國際都市天氣預報",
            "allCountyWeather": []
        }
        # 遍歷 location 並重新組織資料
        for location in data_json["records"]["location"]:
            location_name = location["locationName"]
            weather_elements = location["weatherElement"]
            
            # new_location = {
            #     "locationName": location_name,
            #     "descriptions": []
            # }
            # 遍歷 weatherElement 並提取時間和描述
            sameLocation = f"{location_name}的天氣預報：\n"
            for element in weather_elements:
                for time in element["time"]:
                    sameLocation += f"    『從{time['startTime']} 到 {time['endTime']}之間，{time['description']}。』\n"
                    
            new_data_structure["allCountyWeather"].append({
                "description": sameLocation,
            })
            # new_data_structure["allCountyWeather"].append(new_location)
        # 輸出新的字典結構
        # json_data_final = json.dumps(new_data_structure, ensure_ascii=False, indent=2)
        # print(json_data_final)

        # 轉為string
        json_data_final_string = f"資料集描述: {new_data_structure['datasetDescription']}\n"
        for des in new_data_structure['allCountyWeather']:
            json_data_final_string += f"「{des['description']}」\n"
        # print(json_data_final_string)
        return json_data_final_string

