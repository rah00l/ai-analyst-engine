"""
RAG (Retrieval-Augmented Generation) module for ReconPilot AI.

Usage:
    from rag.pipeline import rag_query
    result = rag_query(question="Why is this file showing as done but not really done?")

    result["answer"]   — the grounded response
    result["sources"]  — which doc/section was used
"""

from rag.pipeline import rag_query

__all__ = ["rag_query"]
