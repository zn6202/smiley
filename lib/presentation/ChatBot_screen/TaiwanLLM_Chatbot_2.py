# This applies to all Taiwan-LLM series.
# yentinglin/Taiwan-LLM-13B-v2.0-chat
# yentinglin/Taiwan-LLM-7B-v2.0.1-chat

from flask import Flask, request, jsonify
from flask_cors import CORS
from ollama import Client
import chatBotUtils
import Example_Chat
# from waitress import serve
from gevent.pywsgi import WSGIServer
import logging

app = Flask(__name__)
CORS(app)
client = Client(host='http://localhost:11434')
model = 'taiwanllm-13b_test_1'
# --------------------------------------------------------------------------------------------------------------------
# 使用者個人化設定
# -----------------

# def getExampleChat():
#     example_chat = [{'role': 'system', 'content': updateSystem()},]
#     example_chat += Example_Chat.getExampleChat()
#     return example_chat

@app.route('/welcome', methods=['POST'])
def welcome():
    userChatHistory = []

    # 取得請求資訊
    message_user_get = request.get_json()
    user_id = message_user_get['user_id']        # 取得使用者ID
    user_name = message_user_get['user_name']    # 取得使用者名稱

    # 取得範例句
    example_chat = [{'role': 'system', 'content': chatBotUtils.updateSystem(user_name)},]
    example_chat += Example_Chat.getExampleChat(user_name)

    # 找尋是否有歷史對話紀錄，若有則添加
    userChatHistory = chatBotUtils.getChatHistory(user_id, user_name)
    if userChatHistory:
        example_chat = example_chat[:1] + userChatHistory + example_chat[1:]

    # 使用者登入後的第一句話
    firstMsg = chatBotUtils.AboutTime.firstMessage()
    # 將使用者問候語加入歷史對話
    user_message = {'role': 'user', 'content': f"「{user_name}」：「{firstMsg}」"}
    example_chat.append(user_message)

    # 生成回覆訊息
    message_assistant = client.chat(model=model, messages=example_chat)
    response_assistant = message_assistant['message']
    # 確認生成訊息不為空或空白
    while(True):
        if (message_assistant.get('message', {}).get('content', '').strip() != ""):
            break
        else:
            message_assistant = client.chat(model=model, messages=example_chat)
            response_assistant = message_assistant['message']

    # 去除多餘空白
    response_assistant['content'].replace(" ", "")
    response_assistant_clean = response_assistant

    # 添加助手回覆訊息至對話紀錄
    example_chat.append(response_assistant_clean)

     # 儲存對話到資料庫
    chatBotUtils.saveToDB_RobotChat(user_id, "user", firstMsg, chatBotUtils.AboutTime.getCurrentTime_forSQL())
    chatBotUtils.saveToDB_RobotChat(user_id, "assistant", response_assistant_clean["content"], chatBotUtils.AboutTime.getCurrentTime_forSQL())
    return jsonify({'response': response_assistant_clean["content"]})

@app.route('/send_message_to_python', methods=['POST'])
def send_message_to_python():
    history_messages = []    # 歷史對話紀錄
    userChatHistory = []     # 使用者對話紀錄
    example_chat = []        # 範例對話

    # 取得請求資訊
    message_user_get = request.get_json()
    user_id = message_user_get['user_id']        # 取得使用者ID
    user_name = message_user_get['user_name']      # 取得使用者名稱
    user_message = message_user_get['messages']    # 取得使用者訊息 {'messages': '嗨'}

    # 取得範例句
    example_chat = [{'role': 'system', 'content': chatBotUtils.updateSystem(user_name)},]
    example_chat += Example_Chat.getExampleChat(user_name)

    # 動態更新 system 訊息
    del example_chat[0]
    example_chat.insert(0, {"role": "system", "content": chatBotUtils.updateSystem(user_name)})

    # 去除重複的對話
    # example_chat = example_chat[:-2]
    print(example_chat)

    # 找尋是否有歷史對話紀錄，若有則添加
    userChatHistory = chatBotUtils.getChatHistory(user_id, user_name)

    if userChatHistory != []:
        history_messages = example_chat + userChatHistory

    # 添加使用者回覆訊息至對話紀錄
    response_user = {'role': 'user', 'content': f'「{user_name}」：「{user_message}」'}     # 將使用者訊息轉為模型可讀取型態
    history_messages.append(response_user)                                                 #    加使用者訊息到歷史紀錄

    # 判斷是否為固定問答句
    fixedMessage = chatBotUtils.getFixedMessage()
    fixedResponse = chatBotUtils.getFixedResponse()
    if (user_message in fixedMessage):
        index = fixedMessage.index(user_message)
        fixedAnswer = fixedResponse[index]                                                  #    取得固定回應句
        response_assistant = {'role': 'assistant', 'content': f'「{chatBotUtils.getAssistantName()}」：「{fixedAnswer}」'}
    else: 
        message_assistant = client.chat(model=model, messages=history_messages)            #    模型生成回應
        response_assistant = message_assistant['message']                                  #    取得模型回應
        # 確認生成訊息不為空或空白
        while(True):
            if (message_assistant.get('message', {}).get('content', '').strip() != ""):
                break
            else:
                message_assistant = client.chat(model=model, messages=example_chat)
                response_assistant = message_assistant['message']

    # 去除多餘空白
    response_assistant['content'].replace(" ", "")
    response_assistant_clean = response_assistant

    # 儲存使用者回覆訊息對話到資料庫
    chatBotUtils.saveToDB_RobotChat(user_id, "user", user_message, chatBotUtils.AboutTime.getCurrentTime_forSQL())
    # 儲存助手回覆訊息對話到資料庫
    chatBotUtils.saveToDB_RobotChat(user_id, "assistant", response_assistant_clean["content"], chatBotUtils.AboutTime.getCurrentTime_forSQL())

    # print(history_messages)
    return jsonify({'response': response_assistant_clean["content"]})                             # 回傳json化的模型回應訊息

if __name__ == '__main__':
    
    # http_server = WSGIServer(('163.22.32.24', 5001), app)
    # print("Server is running on http://163.22.32.24:5001")
    # http_server.serve_forever()
    app.run(port=5001, debug=False)
    # serve(app, host='163.22.32.24', port=5001, threads=4)
