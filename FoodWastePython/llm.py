from langchain_community.agent_toolkits import create_sql_agent
from langchain.sql_database import SQLDatabase
from flask import Flask, request, jsonify

from langchain_openai import ChatOpenAI

app = Flask(__name__)

# Initialize your chatbot outside of the request handling to avoid re-initializing it on every call
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key="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")
db = SQLDatabase.from_uri("sqlite:///rawInv.db")
agent_executor = create_sql_agent(llm, db=db, agent_type="openai-tools", verbose=False)

@app.route('/chat', methods=['POST'])
def chat_with_bot():
    data = request.json
    prompt = data.get('prompt', '')
    # Ensure the prompt adheres to your specified format
    prompt = "Always use the pronoun WE not I. Don't automatically infer what type numbers mean and refer to their name. " + prompt

    try:
        response = agent_executor.invoke(prompt)
        return jsonify({"response": response['output']})
    except Exception as e:
        print(e)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=8080, host='0.0.0.0')

# llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key="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")



# db = SQLDatabase.from_uri("sqlite:///rawInv.db")
# agent_executor = create_sql_agent(llm, db=db, agent_type="openai-tools", verbose=False)
# Prompt = "Always use the pronoun WE not I. Don't automatically infer what type numbers mean and refer to their name. "
# response = agent_executor.invoke(
#     Prompt + "How many Chickens do I have?"
# )
# print(response['output'])

# import os
# os.environ["OPENAI_API_KEY"] = "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"

# from langchain_together import Together

# llm = Together(
#     model="meta-llama/Llama-2-13b-chat-hf",
#     temperature=0.7,
#     max_tokens=128,
#     top_k=1,
#     together_api_key= "12a2bbf732c883b5e261b2b5f3e50d17f1e2e8c4ed4ee886e90bd96a5470312d"
# )