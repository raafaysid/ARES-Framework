import pytest
from telemetry_gen import generate_telemetry
from httpx import AsyncClient, ASGITransport
from telemetry_gen import app  # import the FastAPI app instance


def test_critical_error_trigger():
    """
    test that the monitor correctly sees CRITICAL_ERROR
    when altitude is too high for the remaining battery
    """
    # 600ft alt / 15 = 40% battery limit.
    # with 10% battery, it should trigger CRITICAL_ERROR.
    data = generate_telemetry(1, override_bat=10, override_alt=600)

    assert data["status"] == "CRITICAL_ERROR"
    assert data["battery_pct"] == 10
    assert data["altitude_ft"] == 600
    assert data["monitor_threshold"] == 40.0


def test_low_battery_trigger():
    """
    test that battery < 20 triggers LOW_BATTERY
    as long as it is still above the safety limit
    """
    # 30ft alt / 15 = 2% limit.
    # 15% battery is > 2%, so it should just be LOW_BATTERY
    data = generate_telemetry(1, override_bat=15, override_alt=30)

    assert data["status"] == "LOW_BATTERY"
    assert data["battery_pct"] == 15


def test_ok_status():
    "test that normal flight conditions return OK status"
    # 150ft alt / 15 = 10% limit. 80% battery is plenty.
    data = generate_telemetry(1, override_bat=80, override_alt=150)

    assert data["status"] == "OK"


def test_log_content():
    "verify the telemetry dictionary has all required keys for the iphone app"
    data = generate_telemetry(1)
    expected_keys = [
        "timestamp",
        "id",
        "battery_pct",
        "altitude_ft",
        "status",
        "monitor_threshold"
    ]

    for key in expected_keys:
        assert key in data


@pytest.mark.asyncio
async def test_telemetry_api_status():
    "verify the /telemetry endpoint is reachable and returns 200 OK"
    # using asyncClient to "hit" the FastAPI app internally
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/telemetry")

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/json"

    data = response.json()
    assert "status" in data
    assert "battery_pct" in data


@pytest.mark.asyncio
async def test_api_handles_missing_file(monkeypatch):
    "verifying the API doesnt crash if flight_data.json is missing"
    def mock_failed_gen(*args, **kwargs):
        raise FileNotFoundError("Simulated missing file")
    # replaces the REAL function with MOCK function
    monkeypatch.setattr("telemetry_gen.generate_telemetry", mock_failed_gen)

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/telemetry")

    assert response.status_code != 200
