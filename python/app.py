from fastapi import FastAPI
from datetime import datetime, timezone
import os

app = FastAPI(title="AI Analyst Engine", version="2.0.0-alpha")

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "ai-analyst-engine",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": "2.0.0-alpha",
        "environment": os.getenv("RACK_ENV", "development")
    }
