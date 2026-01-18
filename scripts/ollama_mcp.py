from mcp.server.fastmcp import FastMCP
import ollama

# Initialize the MCP Server
mcp = FastMCP("Ollama Bridge")


@mcp.tool()
def analyze_ui_screenshot(question: str, image_path: str) -> str:
    """
    Uses Ollama's Vision model (MiniCPM-V4.5) to analyze a UI screenshot.
    Use this to check layout, alignment, or describe what is visible.

    Args:
        question: What you want to know about the image (e.g., "Is the button centered?")
        image_path: Absolute path to the screenshot file.
    """
    try:
        response = ollama.chat(
            model="openbmb/minicpm-v4.5",  # Ensure you pulled this model
            messages=[{"role": "user", "content": question, "images": [image_path]}],
        )
        return response["message"]["content"]
    except Exception as e:
        return f"Ollama Vision Error: {str(e)}"


if __name__ == "__main__":
    mcp.run()
