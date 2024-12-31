FROM python:3.12

WORKDIR .

COPY neha_resume.html .

EXPOSE 8000

CMD ["python3", "-m", "http.server", "8000"]

#RUN ./app
