from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from dotenv import load_dotenv
from openai import OpenAI
import os
import uuid

load_dotenv()

app = FastAPI(title="AI Analyst Engine", version="2.0.0-alpha")
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


class AnalyzeRequest(BaseModel):
    question: Optional[str] = None
    context: Optional[Dict[str, Any]] = {}
    session_id: Optional[str] = None


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "ai-analyst-engine",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": "2.0.0-alpha",
        "environment": os.getenv("RACK_ENV", "development")
    }


@app.get("/ready")
def ready():
    return {
        "ready": True,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.get("/info")
def info():
    return {
        "service": "AI Analyst Engine",
        "version": "2.0.0-alpha",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


@app.post("/analyze")
def analyze(payload: AnalyzeRequest):
    question = payload.question

    if not question or not question.strip():
        raise HTTPException(
            status_code=422,
            detail={"error": "question is required", "code": "INVALID_INPUT"}
        )

    session_id = payload.session_id or str(uuid.uuid4())

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are a payment reconciliation assistant. "
                        "Answer questions about reconciliation statuses, "
                        "transaction mismatches, and workflow states clearly and concisely."
                    )
                },
                {"role": "user", "content": question}
            ],
            max_tokens=300
        )
        explanation = response.choices[0].message.content

    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail={"error": "llm_call_failed", "code": "ENGINE_ERROR", "message": str(e)}
        )

    return {
        "session_id": session_id,
        "status": "ok",
        "explanation": explanation,
        "concept": None,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
