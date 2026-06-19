from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
import os
import uuid

app = FastAPI(title="AI Analyst Engine", version="2.0.0-alpha")


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

    # STUB — Phase 2A proves the contract shape only.
    # Real LLM reasoning is added in Step 7.
    return {
        "session_id": session_id,
        "status": "stub",
        "explanation": f"[STUB RESPONSE] Received question: '{question}'",
        "concept": None,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
