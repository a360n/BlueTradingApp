import asyncio
import websockets
import requests
import json
from datetime import datetime

API_KEY = "421b276523c343058c7f577c4e58a89f"
URL = f"https://api.twelvedata.com/time_series?symbol=EUR/USD&interval=1min&apikey={API_KEY}&outputsize=30"


async def send_chart_data(websocket):
    print("📈 Client connected for real chart data")
    try:
        while True:
            response = requests.get(URL)
            data = response.json()

            # تأكد من وجود بيانات
            if "values" in data:
                chart_data = [
                    {
                        "timestamp": item["datetime"],
                        "price": float(item["close"])
                    }
                    for item in reversed(data["values"])
                ]
                await websocket.send(json.dumps(chart_data))
                print("📤 Sent real EUR/USD chart data")
            else:
                print("❌ Error from API:", data.get("message", "Unknown error"))

            await asyncio.sleep(10)  # تحديث كل 10 ثوانٍ
    except websockets.exceptions.ConnectionClosed:
        print("❌ Client disconnected")


async def main():
    async with websockets.serve(send_chart_data, "0.0.0.0", 8002):
        print("🚀 Real Chart WebSocket server running on ws://0.0.0.0:8002")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())