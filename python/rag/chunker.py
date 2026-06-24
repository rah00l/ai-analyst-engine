"""
Chunker — splits markdown handbook docs into retrievable chunks.

Design decisions:
    - Split on ## headers (document-structure-aware chunking)
    - One section = one chunk (no fixed-size splitting needed)
    - Section title is PREPENDED to chunk text (enrichment fix)
      so the embedding captures both the concept name AND the explanation

    Why enrichment matters:
    Without it, the chunk for PARTIAL RECONCILED contains only the explanation
    text — the words "PARTIAL RECONCILED" appear once at most. With enrichment,
    the embedding model sees "PARTIAL RECONCILED: A payment file shows PARTIAL
    RECONCILED when..." — anchoring the vector on both the term and its meaning.
    This measurably improves retrieval accuracy for direct-term questions.
"""

import os
import re
import glob
from typing import List, Dict


def chunk_markdown(filepath: str) -> List[Dict]:
    """
    Split a markdown file into chunks at ## headers.

    Returns a list of dicts:
        - id: unique identifier (filename::slugified_section_title)
        - text: section title + body (enriched)
        - source_doc: which file this came from
        - section_title: the ## header text (for citation)
    """
    with open(filepath, "r") as f:
        content = f.read()

    filename = os.path.basename(filepath)
    parts = re.split(r"\n## ", content)
    chunks = []

    for part in parts[1:]:  # skip preamble before first ##
        lines = part.split("\n", 1)
        title = lines[0].strip()
        body = lines[1].strip() if len(lines) > 1 else ""

        if not body:
            continue

        # Enrichment: prepend section title to body text
        # This helps the embedding model anchor on both term and explanation
        enriched_text = f"{title}: {body}"

        slug = re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_")
        chunk_id = f"{filename}::{slug}"

        chunks.append({
            "id": chunk_id,
            "text": enriched_text,
            "source_doc": filename,
            "section_title": title,
        })

    return chunks


def chunk_all_docs(docs_dir: str = "rag_docs") -> List[Dict]:
    """
    Chunk all markdown files in the docs directory.

    Returns a flat list of all chunks across all documents.
    """
    all_chunks = []
    md_files = sorted(glob.glob(os.path.join(docs_dir, "*.md")))

    if not md_files:
        raise FileNotFoundError(f"No .md files found in {docs_dir}")

    for filepath in md_files:
        chunks = chunk_markdown(filepath)
        all_chunks.extend(chunks)

    return all_chunks


# ============================================================
# Standalone test
# ============================================================
if __name__ == "__main__":
    chunks = chunk_all_docs()
    print(f"Total chunks across all docs: {len(chunks)}")
    print()
    for i, chunk in enumerate(chunks):
        print(f"  {i + 1:2d}. [{chunk['source_doc']}] {chunk['section_title']} "
              f"({len(chunk['text'].split())} words)")
