FROM python:3.12-slim-bookworm AS build
WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --target=/packages -r requirements.txt

FROM python:3.12-slim-bookworm AS runtime
WORKDIR /app
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
COPY --from=build /packages /usr/local/lib/python3.12/site-packages
COPY --chown=app:app app/app.py ./app.py
USER app
EXPOSE 8080
CMD ["python", "app.py"]
