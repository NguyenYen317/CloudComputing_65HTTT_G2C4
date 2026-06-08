import json
from datetime import datetime, timezone
from pathlib import Path

import joblib
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
RUNTIME_DATA_PATH = BASE_DIR / "orders_runtime.csv"
SAMPLE_DATA_PATH = BASE_DIR / "orders_sample.csv"
DATA_PATH = RUNTIME_DATA_PATH if RUNTIME_DATA_PATH.exists() else SAMPLE_DATA_PATH
FOOD_MODEL_PATH = BASE_DIR / "model_food.pkl"
REVENUE_MODEL_PATH = BASE_DIR / "model_revenue.pkl"
OUTPUT_PATH = BASE_DIR / "predictions.json"

FOODS = [
    ("Pizza", "Fast Food", 80000),
    ("Burger", "Fast Food", 50000),
    ("Fried Chicken", "Fast Food", 60000),
    ("Salad", "Healthy", 45000),
    ("Coca", "Drink", 15000),
    ("Milk Tea", "Drink", 35000),
    ("French Fries", "Snack", 30000),
]


def level_for_quantity(quantity: int) -> str:
    if quantity >= 35:
        return "Cao"
    if quantity >= 18:
        return "Trung bình"
    return "Thấp"


def build_prediction_frame() -> pd.DataFrame:
    rows = []
    for food_name, category, price in FOODS:
        for hour in (11, 12, 18, 19, 20):
            rows.append(
                {
                    "foodName": food_name,
                    "category": category,
                    "price": price,
                    "dayOfWeek": 6,
                    "hour": hour,
                    "isWeekend": 1,
                }
            )
    return pd.DataFrame(rows)


def main() -> None:
    for path in (DATA_PATH, FOOD_MODEL_PATH, REVENUE_MODEL_PATH):
        if not path.exists():
            raise FileNotFoundError(
                f"Thiếu file {path.name}. Hãy chạy train_model.py trước."
            )

    historical_df = pd.read_csv(DATA_PATH)
    prediction_df = build_prediction_frame()
    food_model = joblib.load(FOOD_MODEL_PATH)
    revenue_model = joblib.load(REVENUE_MODEL_PATH)

    prediction_df["predictedQuantity"] = food_model.predict(prediction_df).round()
    prediction_df["predictedRevenue"] = revenue_model.predict(prediction_df).round()

    grouped = (
        prediction_df.groupby("foodName", as_index=False)
        .agg({"predictedQuantity": "sum", "predictedRevenue": "sum"})
        .sort_values("predictedQuantity", ascending=False)
    )

    best_selling_foods = [
        {
            "foodName": row.foodName,
            "predictedQuantity": int(row.predictedQuantity),
            "level": level_for_quantity(int(row.predictedQuantity)),
        }
        for row in grouped.head(5).itertuples()
    ]

    tomorrow_revenue = int(prediction_df["predictedRevenue"].sum())
    weekday_factor = historical_df.groupby("dayOfWeek")["totalAmount"].sum().mean()
    next7days = int(max(tomorrow_revenue * 7, weekday_factor * 7))

    top_food_names = grouped.head(2)["foodName"].tolist()
    low_food = grouped.tail(1)["foodName"].iloc[0]

    output = {
        "bestSellingFoods": best_selling_foods,
        "revenuePrediction": {
            "tomorrow": tomorrow_revenue,
            "next7Days": next7days,
        },
        "suggestions": [
            f"Nên nhập thêm nguyên liệu cho {' và '.join(top_food_names)} vì có nhu cầu cao.",
            f"Nên khuyến mãi {low_food} để tăng lượt đặt.",
            "Nên chuẩn bị thêm nhân sự vào khung giờ trưa và tối.",
        ],
    }

    output["updatedAt"] = datetime.now(timezone.utc).isoformat()

    OUTPUT_PATH.write_text(
        json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"Saved predictions: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
