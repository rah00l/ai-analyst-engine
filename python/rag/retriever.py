"""
Retriever — searches the vector store for chunks relevant to a question.

Design decisions:
    - top_k=3 (retrieves 3 candidates from ~55 chunks — good precision/recall balance)
    - Returns structured results with distance scores for transparency
    - Distance thresholds: < 0.4 strong, < 0.6 usable, >= 0.6 weak
"""

from typing import List, Dict, Optional
import chromadb

from rag.embedder import embed_single
from rag.store import get_collection


def retrieve(
    question: str,
    collection: Optional[chromadb.Collection] = None,
    top_k: int = 3
) -> List[Dict]:
    """
    Find the most relevant chunks for a given question.

    Args:
        question: the user's question (natural language)
        collection: ChromaDB collection to search (uses default if not provided)
        top_k: number of results to return

    Returns:
        list of result dicts, each containing:
            - text: the chunk content
            - source_doc: which file it came from
            - section_title: which section (for citation)
            - distance: cosine distance (lower = better match)
    """
    if collection is None:
        collection = get_collection()

    query_vector = embed_single(question)

    results = collection.query(
        query_embeddings=[query_vector],
        n_results=top_k,
        include=["documents", "metadatas", "distances"]
    )

    retrieved = []
    for i in range(len(results["documents"][0])):
        retrieved.append({
            "text": results["documents"][0][i],
            "source_doc": results["metadatas"][0][i]["source_doc"],
            "section_title": results["metadatas"][0][i]["section_title"],
            "distance": round(results["distances"][0][i], 4),
        })

    return retrieved


# ============================================================
# Standalone test
# ============================================================
if __name__ == "__main__":
    question = "Why is this file showing as done but not really done?"
    print(f"Question: {question}\n")

    results = retrieve(question)
    for i, r in enumerate(results):
        quality = "STRONG" if r["distance"] < 0.4 else "WEAK" if r["distance"] < 0.6 else "POOR"
        print(f"  {i + 1}. [{quality}] {r['section_title']} "
              f"(dist: {r['distance']}, from {r['source_doc']})")
