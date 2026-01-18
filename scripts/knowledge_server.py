import os
import re
import json
import fnmatch
from typing import List, Optional, Dict, Any
from dataclasses import dataclass, field
from enum import Enum
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("NimKnowledgeBase")

DOCS_PATH = "./refs"
INDEX_CACHE_FILE = "./.nim_docs_index.json"


@dataclass
class LibraryIndex:
    name: str
    path: str
    description: str
    sections: List[Dict[str, Any]] = field(default_factory=list)
    headers: List[Dict[str, Any]] = field(default_factory=list)
    topics: List[str] = field(default_factory=list)
    file_mtime: float = 0.0


class SearchType(Enum):
    SUBSTRING = "substring"
    REGEX = "regex"
    TOPIC = "topic"


def load_library_index() -> Dict[str, LibraryIndex]:
    if not os.path.exists(INDEX_CACHE_FILE):
        return build_library_index()

    try:
        with open(INDEX_CACHE_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            cached_index = {k: LibraryIndex(**v) for k, v in data.items()}
    except Exception:
        return build_library_index()

    libraries: Dict[str, LibraryIndex] = {}
    libs_to_rebuild: List[str] = []

    for lib_key, lib in cached_index.items():
        full_context_file = os.path.join(lib.path, f"{lib.name}_full_context.txt")
        if not os.path.exists(full_context_file):
            libs_to_rebuild.append(lib_key)
            continue

        current_mtime = os.path.getmtime(full_context_file)
        if abs(current_mtime - lib.file_mtime) > 0.001:
            libs_to_rebuild.append(lib_key)
        else:
            libraries[lib_key] = lib

    if libs_to_rebuild:
        rebuilt = build_libraries(libs_to_rebuild)
        libraries.update(rebuilt)
        try:
            with open(INDEX_CACHE_FILE, "w", encoding="utf-8") as f:
                json.dump({k: v.__dict__ for k, v in libraries.items()}, f, indent=2)
        except Exception:
            pass

    return libraries


def build_libraries(lib_names: List[str]) -> Dict[str, LibraryIndex]:
    libraries: Dict[str, LibraryIndex] = {}

    for item in lib_names:
        lib_path = os.path.join(DOCS_PATH, item)
        if not os.path.isdir(lib_path):
            continue

        full_context_file = os.path.join(lib_path, f"{item}_full_context.txt")
        if not os.path.exists(full_context_file):
            continue

        index = LibraryIndex(
            name=item, path=lib_path, description="", sections=[], headers=[], topics=[]
        )

        try:
            with open(full_context_file, "r", encoding="utf-8") as f:
                content = f.read()
                lines = content.split("\n")

                in_section = False
                current_section: Dict[str, Any] = {}
                section_count = 0
                found_headers: List[Dict[str, Any]] = []
                found_topics: set = set()

                for i, line in enumerate(lines):
                    header_match = re.match(r"^(#{1,6})\s+(.+)$", line)
                    if header_match:
                        level = len(header_match.group(1))
                        title = header_match.group(2).strip()
                        header_entry: Dict[str, Any] = {
                            "title": title,
                            "level": level,
                            "line": i,
                        }
                        found_headers.append(header_entry)
                        found_topics.update(extract_topics(title))
                        section_count += 1
                        current_section = {
                            "title": title,
                            "level": level,
                            "start_line": i,
                            "line_count": 0,
                        }
                        index.sections.append(current_section)
                        in_section = True
                    elif in_section and line.startswith("--- END OF FILE:"):
                        index.sections[-1]["end_line"] = i
                        index.sections[-1]["line_count"] = (
                            i - index.sections[-1]["start_line"]
                        )
                        in_section = False
                    elif in_section:
                        index.sections[-1]["line_count"] = (
                            i - index.sections[-1]["start_line"]
                        )

                index.headers = found_headers
                index.topics = sorted(list(found_topics))

                first_desc = extract_description(content)
                index.description = first_desc

                index.file_mtime = os.path.getmtime(full_context_file)

        except Exception as e:
            print(f"Error indexing {item}: {e}")
            continue

        libraries[item.lower()] = index

    return libraries


def build_library_index() -> Dict[str, LibraryIndex]:
    if not os.path.exists(DOCS_PATH):
        return {}

    all_libs = [
        item
        for item in os.listdir(DOCS_PATH)
        if os.path.isdir(os.path.join(DOCS_PATH, item))
    ]

    libraries = build_libraries(all_libs)

    try:
        with open(INDEX_CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump({k: v.__dict__ for k, v in libraries.items()}, f, indent=2)
    except Exception:
        pass

    return libraries


def extract_description(content: str) -> str:
    first_lines = content.split("\n")[:20]
    desc_parts = []
    for line in first_lines:
        line = line.strip()
        if line and not line.startswith("#") and not line.startswith("---"):
            desc_parts.append(line)
        if len(desc_parts) > 3:
            break
    return " ".join(desc_parts[:3])[:200]


def extract_topics(text: str) -> List[str]:
    topics = set()
    words = re.findall(r"\b[a-zA-Z][a-zA-Z0-9]*\b", text.lower())
    topic_keywords = {
        "tutorial",
        "guide",
        "example",
        "api",
        "reference",
        "install",
        "config",
        "usage",
        "quickstart",
        "getting started",
        "advanced",
        "basic",
        "introduction",
        "overview",
        "docs",
        "documentation",
    }
    for word in words:
        if word in topic_keywords:
            topics.add(word)
    if "example" in topics:
        topics.add("examples")
    return list(topics)


def rank_match(content: str, query: str, search_type: SearchType) -> float:
    content_lower = content.lower()
    query_lower = query.lower()

    if search_type == SearchType.REGEX:
        try:
            matches = list(re.finditer(query, content, re.IGNORECASE))
            if not matches:
                return 0.0
            score = len(matches) * 0.5
            for m in matches[:5]:
                pos = m.start()
                context_start = max(0, pos - 50)
                context_end = min(len(content), pos + 50)
                context = content[context_start:context_end].lower()
                header_bonus = (
                    2.0 if any(h in context for h in ["#", "##", "###"]) else 0
                )
                code_bonus = 1.5 if "```" in context else 0
                score += header_bonus + code_bonus
            return min(score, 10.0)
        except re.error:
            return 0.0

    count = content_lower.count(query_lower)
    if count == 0:
        return 0.0

    score = count * 0.3

    if (
        content_lower.startswith(query_lower)
        or content_lower[:100].count(query_lower) > 0
    ):
        score += 1.0

    code_match = "```" in content and any(
        c in content_lower for c in ["proc", "func", "type", "var", "let", "import"]
    )
    if code_match:
        score += 0.5

    header_bonus = 1.0 if any(h in content_lower[:200] for h in ["#", "##"]) else 0
    score += header_bonus

    return min(score, 10.0)


LIBRARY_INDEX = load_library_index()


@mcp.tool()
def list_nim_libraries() -> str:
    """
    List all available Nim library documentation in the knowledge base.

    Returns:
        JSON list of libraries with name, description, topics, and section count.
    """
    if not LIBRARY_INDEX:
        return "No documentation libraries found."

    result = {
        "count": len(LIBRARY_INDEX),
        "libraries": [
            {
                "name": lib.name,
                "description": lib.description,
                "topics": lib.topics,
                "section_count": len(lib.sections),
                "header_count": len(lib.headers),
            }
            for lib in LIBRARY_INDEX.values()
        ],
    }

    output = f"Available Nim Documentation Libraries ({result['count']}):\n\n"
    for lib in result["libraries"]:
        topics_str = ", ".join(lib["topics"]) if lib["topics"] else "general"
        output += f"• {lib['name']}\n"
        output += f"  Topics: {topics_str}\n"
        output += (
            f"  Sections: {lib['section_count']}, Headers: {lib['header_count']}\n"
        )
        if lib["description"]:
            output += f"  {lib['description'][:100]}...\n"
        output += "\n"

    return output


@mcp.tool()
def get_nim_library_toc(library_name: str = "") -> str:
    """
    Get the table of contents/headers for a specific library or all libraries.

    Args:
        library_name: (Optional) Name of library to get TOC for (e.g., "necsus", "nim-chronos").
                      If not provided, returns TOC for all libraries.
    """
    if not LIBRARY_INDEX:
        return "No documentation libraries found."

    if library_name:
        lib_key = library_name.lower()
        if lib_key not in LIBRARY_INDEX:
            available = ", ".join(lib.name for lib in LIBRARY_INDEX.values())
            return f"Library '{library_name}' not found. Available: {available}"

        lib = LIBRARY_INDEX[lib_key]
        output = f"Table of Contents: {lib.name}\n{'=' * 40}\n\n"

        for header in lib.headers:
            indent = "  " * (header["level"] - 1)
            line_num = header["line"]
            output += f"{indent}• {header['title']} (line {line_num})\n"

        output += f"\nTopics: {', '.join(lib.topics)}\n"
        output += f"Total sections: {len(lib.sections)}\n"

        return output

    output = "All Library Tables of Contents\n" + "=" * 40 + "\n\n"
    for lib in LIBRARY_INDEX.values():
        output += f"--- {lib.name} ({len(lib.headers)} headers) ---\n"
        top_headers = [h for h in lib.headers if h["level"] == 1][:5]
        for h in top_headers:
            output += f"  • {h['title']}\n"
        if len(lib.headers) > 5:
            output += f"  ... and {len(lib.headers) - 5} more\n"
        output += "\n"

    return output


@mcp.tool()
def search_nim_docs(
    query: str,
    library_name: str = "",
    search_type: str = "substring",
    max_results: int = 5,
) -> str:
    """
    Search the Nim library documentation for specific concepts, syntax, or patterns.

    Args:
        query: The specific concept, syntax, or pattern to search for
               (e.g., "async http request", "pointer casting", "Query.*ptr")
        library_name: (Optional) Limit search to a specific library (e.g., "necsus", "nim-chronos")
        search_type: Type of search - "substring", "regex", or "topic" (default: "substring")
        max_results: Maximum number of results to return (default: 5, max: 20)
    """
    max_results = min(max_results, 20)

    if not LIBRARY_INDEX:
        return "No documentation libraries available."

    libraries_to_search: List[LibraryIndex] = []
    if library_name:
        lib_key = library_name.lower()
        if lib_key not in LIBRARY_INDEX:
            available = ", ".join(lib.name for lib in LIBRARY_INDEX.values())
            return f"Library '{library_name}' not found. Available: {available}"
        libraries_to_search = [LIBRARY_INDEX[lib_key]]
    else:
        libraries_to_search = list(LIBRARY_INDEX.values())

    search_type_enum = SearchType(search_type)

    results: List[Dict[str, Any]] = []
    for lib in libraries_to_search:
        filepath = os.path.join(lib.path, f"{lib.name}_full_context.txt")
        if not os.path.exists(filepath):
            continue

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            if search_type_enum == SearchType.TOPIC:
                matches: List[tuple] = []
                for section in lib.sections:
                    if query.lower() in section.get("title", "").lower():
                        matches.append((section, 5.0))
                for header in lib.headers:
                    if query.lower() in header["title"].lower():
                        matches.append((header, 3.0))
                for t in lib.topics:
                    if query.lower() in t.lower():
                        topic_match: List[Dict[str, str]] = [{"topic": t}]
                        matches.append((topic_match, 2.0))
                        break
                for match, score in matches[:max_results]:
                    results.append(
                        {
                            "library": lib.name,
                            "match": match,
                            "score": score,
                            "type": "topic",
                        }
                    )
            else:
                content_lower = content.lower()
                query_lower = query.lower()

                if search_type_enum == SearchType.SUBSTRING:
                    lines = content.split("\n")
                    for i, line in enumerate(lines):
                        if query_lower in line.lower():
                            score = rank_match(content, query, search_type_enum)
                            start = max(0, i - 3)
                            end = min(len(lines), i + 10)
                            snippet = "\n".join(lines[start:end])
                            results.append(
                                {
                                    "library": lib.name,
                                    "match": {"line": i, "snippet": snippet},
                                    "score": score,
                                    "type": "substring",
                                }
                            )
                            if len(results) >= max_results * 3:
                                break
                else:
                    score = rank_match(content, query, search_type_enum)
                    if score > 0:
                        lines = content.split("\n")
                        matched_lines: List[int] = []
                        pattern = re.compile(query, re.IGNORECASE)
                        for i, line in enumerate(lines):
                            if pattern.search(line):
                                matched_lines.append(i)
                                if len(matched_lines) >= 10:
                                    break
                        if matched_lines:
                            start = max(0, matched_lines[0] - 3)
                            end = min(len(lines), matched_lines[-1] + 10)
                            snippet = "\n".join(lines[start:end])
                            results.append(
                                {
                                    "library": lib.name,
                                    "match": {
                                        "lines": matched_lines,
                                        "snippet": snippet,
                                    },
                                    "score": score,
                                    "type": "regex",
                                }
                            )

        except Exception:
            continue

    if not results:
        return f"No results found for '{query}' in the documentation."

    results.sort(key=lambda x: x["score"], reverse=True)
    results = results[:max_results]

    output = (
        f"Search Results for '{query}' ({len(results)} matches):\n" + "=" * 50 + "\n\n"
    )

    for i, r in enumerate(results, 1):
        output += f"[{i}] {r['library']} (score: {r['score']:.1f}, type: {r['type']})\n"
        match = r["match"]
        if r["type"] == "substring":
            output += f"    Line {match['line']}:\n"
            output += f"    {match['snippet'][:300]}\n"
        elif r["type"] == "regex":
            output += f"    Lines: {match['lines']}\n"
            output += f"    {match['snippet'][:300]}\n"
        elif r["type"] == "topic":
            output += f"    {match}\n"
        output += "\n"

    return output


@mcp.tool()
def get_nim_doc_section(library_name: str, section_title: str = "") -> str:
    """
    Get the full content of a specific documentation section.

    Args:
        library_name: Name of the library (e.g., "necsus", "nim-chronos")
        section_title: (Optional) Title of section to retrieve. If not provided,
                       returns the introduction/first section.
    """
    lib_key = library_name.lower()
    if lib_key not in LIBRARY_INDEX:
        available = ", ".join(lib.name for lib in LIBRARY_INDEX.values())
        return f"Library '{library_name}' not found. Available: {available}"

    lib = LIBRARY_INDEX[lib_key]
    filepath = os.path.join(lib.path, f"{lib.name}_full_context.txt")

    if not os.path.exists(filepath):
        return f"Documentation file not found for {library_name}"

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            lines = content.split("\n")

        if not section_title:
            first_content = []
            in_file = False
            for line in lines:
                if line.startswith("--- START OF FILE:"):
                    in_file = True
                    continue
                if in_file and line.startswith("--- END OF FILE:"):
                    break
                if in_file and line.strip():
                    first_content.append(line)
                elif in_file and not line.strip() and first_content:
                    break
            return "\n".join(first_content[:50])

        section_content: List[str] = []
        found_section = False
        for i, line in enumerate(lines):
            if section_title.lower() in line.lower() and line.strip().startswith("#"):
                found_section = True
                section_content.append(line)
                continue
            elif found_section:
                if line.startswith("--- END OF FILE:") or (
                    line.strip().startswith("#")
                    and section_title.lower() not in line.lower()
                ):
                    break
                section_content.append(line)
                if len(section_content) > 100:
                    break

        if not section_content:
            return f"Section '{section_title}' not found in {library_name}"

        return "\n".join(section_content)

    except Exception as e:
        return f"Error reading section: {e}"


@mcp.tool()
def extract_nim_code_examples(library_name: str = "") -> str:
    """
    Extract and format all Nim code examples from documentation.

    Args:
        library_name: (Optional) Name of library to extract from. If not provided,
                      extracts from all libraries.
    """
    libraries_to_search: List[LibraryIndex] = []
    if library_name:
        lib_key = library_name.lower()
        if lib_key not in LIBRARY_INDEX:
            available = ", ".join(lib.name for lib in LIBRARY_INDEX.values())
            return f"Library '{library_name}' not found. Available: {available}"
        libraries_to_search = [LIBRARY_INDEX[lib_key]]
    else:
        libraries_to_search = list(LIBRARY_INDEX.values())

    all_examples: List[Dict[str, Any]] = []

    for lib in libraries_to_search:
        filepath = os.path.join(lib.path, f"{lib.name}_full_context.txt")
        if not os.path.exists(filepath):
            continue

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            pattern = r"```nim\s*\n(.*?)\n```"
            matches = re.findall(pattern, content, re.DOTALL)

            for i, code in enumerate(matches, 1):
                if len(code.strip()) > 10:
                    all_examples.append(
                        {"library": lib.name, "example_num": i, "code": code.strip()}
                    )

        except Exception:
            continue

    if not all_examples:
        return "No code examples found."

    output = f"Nim Code Examples ({len(all_examples)} total):\n" + "=" * 50 + "\n\n"

    current_lib = ""
    for ex in all_examples:
        if ex["library"] != current_lib:
            current_lib = ex["library"]
            output += f"\n--- {current_lib} ---\n\n"
        output += f"Example {ex['example_num']}:\n"
        output += f"```nim\n{ex['code']}\n```\n\n"

    return output


if __name__ == "__main__":
    mcp.run()
