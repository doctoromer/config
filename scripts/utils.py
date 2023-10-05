import logging
from pathlib import Path

try:
    from rich.logging import RichHandler
except ImportError:
    RichHandler = None


ROOT_DIR = Path(__file__).parent.parent.absolute()


def configure_logger(verbose):
    if RichHandler is not None:
        handler = RichHandler(rich_tracebacks=True, tracebacks_show_locals=True)
    else:
        handler = logging.StreamHandler()

    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)-15s - %(levelname)s - %(message)s",
        datefmt="[%X]",
        handlers=[handler],
    )
