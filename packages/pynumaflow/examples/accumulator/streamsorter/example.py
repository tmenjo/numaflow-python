import logging
import os
from collections.abc import AsyncIterable
from datetime import datetime

from pynumaflow import setup_logging
from pynumaflow.accumulator import Accumulator, AccumulatorAsyncServer
from pynumaflow.accumulator import (
    Message,
    Datum,
)
from pynumaflow.shared.asynciter import NonBlockingIterator

_LOGGER = setup_logging(__name__)
if os.getenv("PYTHONDEBUG"):
    _LOGGER.setLevel(logging.DEBUG)


class StreamSorter(Accumulator):
    def __init__(self):
        _LOGGER.info("StreamSorter initialized")
        self.latest_wm = datetime.fromtimestamp(-1)
        self.sorted_buffer: list[Datum] = []

    async def handler(
        self,
        datums: AsyncIterable[Datum],
        output: NonBlockingIterator,
    ):
        _LOGGER.info("StreamSorter handler started")
        async for datum in datums:
            _LOGGER.info(
                f"Received datum with event time: {datum.event_time}, "
                f"Current latest watermark: {self.latest_wm}, "
                f"Datum watermark: {datum.watermark}"
            )


if __name__ == "__main__":
    grpc_server = None
    grpc_server = AccumulatorAsyncServer(StreamSorter)
    grpc_server.start()
