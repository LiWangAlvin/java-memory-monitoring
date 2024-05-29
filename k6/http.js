import http from 'k6/http';
import {
    check,
    sleep
} from 'k6';

export const options = {
  discardResponseBodies: true,
  scenarios: {
    contacts: {
      executor: 'constant-arrival-rate',

      // How long the test lasts
      duration: '5m',

      // How many iterations per timeUnit
      rate: 1000,

      // Start `rate` iterations per second
      timeUnit: '1s',

      // Pre-allocate 2 VUs before starting the test
      preAllocatedVUs: 500,

      // Spin up a maximum of 50 VUs to sustain the defined
      // constant arrival rate.
      maxVUs: 1000,
    },
  },
};

export default function () {
    const url = 'http://120.25.202.23:8080/';

    const payload = JSON.stringify({
        "data": [
            "1511f15a40abfc856b44a0d3ecb51d19823895139bdb85e7818e2f0ef9bdcde42ba1342e0b76c904d16784507945e712d752682aac7b9ac94c3cf220="
        ]
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    let res = http.post(url, payload, params);

    check(res, {
        'is status 200': (r) => r.status === 200,
    });

    // sleep(1);
}