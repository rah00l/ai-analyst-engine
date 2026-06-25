from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from typing import Optional, Dict, Any
from dotenv import load_dotenv
import os
import uuid

from rag.pipeline import initialize, rag_query

load_dotenv()

app = FastAPI(title="AI Analyst Engine", version="2.0.0-alpha")


@app.on_event("startup")
def startup_event():
    """Initialize RAG pipeline on app startup — chunks, embeds, and stores all handbook docs."""
    count = initialize(docs_dir="rag_docs", persistent=True)
    print(f"RAG initialized with {count} chunks")


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
        result = rag_query(question)
    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail={"error": "rag_query_failed", "code": "ENGINE_ERROR", "message": str(e)}
        )

    return {
        "session_id": session_id,
        "status": "ok",
        "explanation": result["answer"],
        "sources": result["sources"],
        "concept": result["retrieved_chunks"][0]["section_title"] if result["retrieved_chunks"] else None,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
