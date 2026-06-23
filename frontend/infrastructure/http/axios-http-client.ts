import { HttpRequest, HttpResponse, HttpClient } from "../../shared_domain/index.ts";
import axios, { AxiosResponse } from "axios";

const MAX_RETRIES = 2;
const RETRY_DELAY_MS = 300;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export class AxiosHttpClient implements HttpClient {
  async request(data: HttpRequest): Promise<HttpResponse> {
    let lastError: unknown;
    let attempt = 0;

    while (attempt <= MAX_RETRIES) {
      try {
        const axiosResponse: AxiosResponse = await axios.request({
          url: data.url,
          method: data.method,
          data: data.body,
          headers: data.headers,
          validateStatus: () => true,
        });

        if (axiosResponse.status >= 500 && attempt < MAX_RETRIES) {
          attempt++;
          await sleep(RETRY_DELAY_MS * attempt);
          continue;
        }

        return {
          statusCode: axiosResponse.status,
          body: axiosResponse.data,
        };
      } catch (error) {
        lastError = error;
        if (attempt < MAX_RETRIES) {
          attempt++;
          await sleep(RETRY_DELAY_MS * attempt);
          continue;
        }
      }
    }

    return {
      statusCode: 500,
      body: { error: lastError instanceof Error ? lastError.message : "Network error" },
    };
  }
}
