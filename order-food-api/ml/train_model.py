from pathlib import Path

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder


BASE_DIR = Path(__file__).resolve().parent
RUNTIME_DATA_PATH = BASE_DIR / "orders_runtime.csv"
SAMPLE_DATA_PATH = BASE_DIR / "orders_sample.csv"
DATA_PATH = RUNTIME_DATA_PATH if RUNTIME_DATA_PATH.exists() else SAMPLE_DATA_PATH
FOOD_MODEL_PATH = BASE_DIR / "model_food.pkl"
REVENUE_MODEL_PATH = BASE_DIR / "model_revenue.pkl"

CATEGORICAL_FEATURES = ["foodName", "category"]
NUMERIC_FEATURES = ["price", "dayOfWeek", "hour", "isWeekend"]
FEATURES = CATEGORICAL_FEATURES + NUMERIC_FEATURES


def build_model() -> Pipeline:
    preprocessor = ColumnTransformer(
        transformers=[
            ("category", OneHotEncoder(handle_unknown="ignore"), CATEGORICAL_FEATURES),
            ("number", "passthrough", NUMERIC_FEATURES),
        ]
    )

    regressor = RandomForestRegressor(
        n_estimators=160,
        random_state=42,
        min_samples_leaf=2,
    )

    return Pipeline(
        steps=[
            ("preprocessor", preprocessor),
            ("regressor", regressor),
        ]
    )


def train_target(df: pd.DataFrame, target: str, output_path: Path) -> float:
    x = df[FEATURES]
    y = df[target]
    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.2, random_state=42
    )

    model = build_model()
    model.fit(x_train, y_train)
    prediction = model.predict(x_test)
    mae = mean_absolute_error(y_test, prediction)

    joblib.dump(model, output_path)
    return mae


def main() -> None:
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Không tìm thấy dữ liệu mẫu: {DATA_PATH}")

    df = pd.read_csv(DATA_PATH)
    if len(df) < 5:
        raise ValueError("Cần ít nhất 5 dòng dữ liệu đơn hàng để huấn luyện model.")

    food_mae = train_target(df, "quantity", FOOD_MODEL_PATH)
    revenue_mae = train_target(df, "totalAmount", REVENUE_MODEL_PATH)

    print("Training completed")
    print(f"Training data: {DATA_PATH}")
    print(f"Saved food model: {FOOD_MODEL_PATH}")
    print(f"Saved revenue model: {REVENUE_MODEL_PATH}")
    print(f"Quantity MAE: {food_mae:.2f}")
    print(f"Revenue MAE: {revenue_mae:.2f}")


if __name__ == "__main__":
    main()
