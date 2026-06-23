import { AxiosHttpClient } from "../../infrastructure/http/axios-http-client.ts";

export const makeAxiosHttpClient = (): AxiosHttpClient => new AxiosHttpClient();
