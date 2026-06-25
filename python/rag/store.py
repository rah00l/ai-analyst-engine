"""
Store — manages the ChromaDB vector store.

Design decisions:
    - Uses PersistentClient for local dev (survives container restarts with volume mount)
    - Uses EphemeralClient as fallback for Railway (re-embeds on startup, acceptable at ~55 chunks)
    - Collection uses cosine similarity (standard for text embeddings)
    - Rebuilds collection from scratch on each load (idempotent, no stale data)
"""

import os
from typing import List, Dict, Optional
import chromadb

COLLECTION_NAME = "recon_handbook"
CHROMA_DB_PATH = "./chroma_db"


def get_client(persistent: bool = True) -> chromadb.ClientAPI:
    """
    Get a ChromaDB client.

    Args:
        persistent: if True, uses disk storage (local dev with volume mount).
                    if False, uses in-memory (Railway/ephemeral environments).
    """
    if persistent:
        return chromadb.PersistentClient(path=CHROMA_DB_PATH)
    else:
        return chromadb.EphemeralClient()


def load_collection(
    chunks: List[Dict],
    embeddings: List[List[float]],
    client: Optional[chromadb.ClientAPI] = None
) -> chromadb.Collection:
    """
    Create (or recreate) the handbook collection with pre-embedded chunks.

    Args:
        chunks: list of chunk dicts (from chunker.chunk_all_docs)
        embeddings: list of vectors (from embedder.embed_texts), same order as chunks
        client: optional ChromaDB client (creates persistent one if not provided)

    Returns:
        the loaded ChromaDB collection, ready for queries
    """
    if client is None:
        client = get_client(persistent=True)

    # Delete existing collection if present (clean rebuild)
    try:
        client.delete_collection(COLLECTION_NAME)
    except Exception:
        pass

    collection = client.create_collection(
        name=COLLECTION_NAME,
        metadata={"hnsw:space": "cosine"}
    )

    collection.add(
        ids=[chunk["id"] for chunk in chunks],
        embeddings=embeddings,
        documents=[chunk["text"] for chunk in chunks],
        metadatas=[
            {
                "source_doc": chunk["source_doc"],
                "section_title": chunk["section_title"]
            }
            for chunk in chunks
        ]
    )

    return collection


def get_collection(client: Optional[chromadb.ClientAPI] = None) -> chromadb.Collection:
    """
    Get an existing collection (for query time, after load_collection has run).
    """
    if client is None:
        client = get_client(persistent=True)
    return client.get_collection(COLLECTION_NAME)


# ============================================================
# Standalone test
# ============================================================
if __name__ == "__main__":
    client = get_client()
    try:
        collection = get_collection(client)
        print(f"Collection '{COLLECTION_NAME}' exists with {collection.count()} records")
    except Exception:
        print(f"Collection '{COLLECTION_NAME}' does not exist yet. Run pipeline.initialize() first.")
