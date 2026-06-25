"""
RAG (Retrieval-Augmented Generation) module for ReconPilot AI.

Usage:
    from rag.pipeline import rag_query
    result = rag_query(question="Why is this file showing as done but not really done?")
"""

from rag.pipeline import rag_query

__all__ = ["rag_query"]
