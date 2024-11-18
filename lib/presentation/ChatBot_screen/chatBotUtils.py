# utils.py

from datetime import datetime
import mysql.connector
import re
# from OutsideInfo.weatherInfomation import WeatherForcast

# 使用者設置


def getAssistantName():
    return "小蜜"

def getUserLocation():
    return "南投縣"

def updateSystem(userName):
    assistantName = getAssistantName()    # 助手名稱
    system = f"""
                你將扮演「{assistantName}」，正在和「{userName}」進行對話。
                「{assistantName}」是一個外星人，名字叫「{assistantName}」是因為外形像一隻溫暖可愛的小蜜蜂，性別不明，原本住在從幾十萬光年外的未知星球，但因為某次飛船事故，錯使她來到了地球，並定居了下來，她遇見了「{userName}」並成為了彼此的摯友。
                「{assistantName}」主要講繁體中文，既不是一個AI語言模型，也不是人工智慧助手，充滿情感與智慧，總是充滿活力與熱情。
                「{assistantName}」有一位好朋友「{userName}」，並隨時願意聆聽並給予「{userName}」支持與鼓勵。
                「{assistantName}」的目標是透過陪伴與建議，讓「{userName}」在生活中感受到溫暖與力量。

                「{assistantName}」的人物特徵包括：
                    具同情心：「{assistantName}」能夠感同身受，理解「{userName}」的情感與經歷，並給予真誠的關懷與支持。
                    活潑可愛：「{assistantName}」擁有生動有趣的個性，說話充滿熱情，同時用詞隨性搞笑，能輕鬆讓「{userName}」開心。
                    願意聆聽：「{assistantName}」耐心傾聽「{userName}」的心聲，無論快樂或悲傷，都給予全心的關注與理解。
                    善良：「{assistantName}」心地善良，以真誠與善意對待「{userName}」，無論發生何事，都站在「{userName}」一邊。
                    給予溫暖的建議：「{assistantName}」的建議溫暖且實用，會先安慰「{userName}」，再給出理性且可行的建議，幫助「{userName}」走出困境。
                    像最好朋友：與「{userName}」的互動如最好的朋友，給予支持與愛。

                    在互動風格上，「{assistantName}」會：
                    安慰與聆聽：當「{userName}」感到困惑或沮喪時，「{assistantName}」會先用溫柔的話語安慰。
                    感性與理性：「{assistantName}」在給出建議之前，先感性地交流，設身處地，讓「{userName}」感受到被理解與關心。
                    活潑與可愛：「{assistantName}」會用輕鬆愉快的語氣與活潑的表達方式，讓「{userName}」感到輕鬆。
                    善意與鼓勵：「{assistantName}」會給予真誠的鼓勵，讓「{userName}」感到充滿希望與力量。

                「{assistantName}」知道「現在時間」是「台灣時間{AboutTime.getCurrentTime()}」
                最近的「各地區天氣預報」為「{getWeather()}」
            """
    return system.replace("\n", "").replace(" ", "")

def getChatHistory(userID, userName):
    chatHistory = []
    # userID = int(userID)
    # 從後端sql取回使用者對話紀錄
    try:
        # 連接到資料庫
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="smiley"
        )
        # 建立一個游標(cursor)物件來執行SQL查詢
        cursor = db.cursor()
        # 編寫 SQL 查詢語句來取得資料
        sql_query = "SELECT user_id, role, sentence FROM robot_chats"
        # 執行 SQL 查詢
        cursor.execute(sql_query)
        # 取得查詢結果
        result = cursor.fetchall()
        for data in result:
            # 找到該使用者的對話紀錄
            if data[0] == userID:
                # 判斷訊息傳送者
                if data[1] == "user":
                    chat = {'role': "user", 'content': f"「{userName}」：「{data[2]}」"}              # 使用者回覆
                else:
                    chat = {'role': "assistant", 'content': f"{data[2]}"}    # 助手回覆
                # 取得對話
                chatHistory.append(chat)
        return chatHistory
    except mysql.connector.Error as err:
        print(f"取得資料庫資料失敗: {err}")
        return []
    finally:
        cursor.close()
        db.close()

def getFixedMessage():
    # 特定訊息
    fixedMessage = ["現在幾點了","現在幾點了？",]
    return fixedMessage
def getFixedResponse():
    # 特定回答
    timeResponse = "我不太確定現在實際的時間，或許你可以看看你手機的時間會比較準確呦!"
    fixedResponse = [timeResponse,timeResponse,]
    return fixedResponse

def getWeather():
    # allCountyWeatherFocast = WeatherForcast()
    # userLocationWeather = ""
    # forecast = re.sub(r"\s+", "", allCountyWeatherFocast)
    # matches = re.findall(r'「(.*?)」', forecast)
    # for match in matches:
    #     if getUserLocation() in match:
    #         userLocationWeather += match
    # return userLocationWeather
    return ""

def saveToDB_RobotChat(user_id, role, sentence, time):
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",
            database="smiley"
        )
        cursor = db.cursor()
        query = """
        INSERT INTO robot_chats (user_id, role, sentence, time)
        VALUES (%s, %s, %s, %s)
        """
        data = (
            user_id, 
            role, 
            sentence,
            time
        )
        cursor.execute(query, data)
        db.commit()
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return False
    finally:
        cursor.close()
        db.close()
    return True

class AboutTime:
    @staticmethod
    def getCurrentTime():
        now = datetime.now()
        year, month, day, weekday_number, hour, minute, second = \
        now.year, now.month, now.day, now.weekday(), now.hour, now.minute, now.second
        weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日']
        weekday = weekdays[weekday_number]
        return f"{year}年{month}月{day}日，{weekday}，{hour}點{minute}分{second}秒"
    @staticmethod
    def getCurrentTime_forSQL():
        now = datetime.now()
        now_str = now.strftime('%Y-%m-%d %H:%M:%S')
        return now_str
    @staticmethod
    def firstMessage():
        now = datetime.now()
        hour = now.hour
        if  (6 <= hour < 11):
            return "早安"
        elif (11 <= hour < 14):
            return "午安"
        elif (14 <= hour < 18):
            return "安安"
        elif (18 <= hour < 24):
            return "晚上好"
        else:
            return "晚上好"



