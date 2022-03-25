/*
 * Copyright 2002-2014 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.squareup.connectexamples.ecommerce;

import com.squareup.square.Environment;
import com.squareup.square.api.PaymentsApi;
import com.squareup.square.models.*;
import com.squareup.square.SquareClient;
import com.squareup.square.exceptions.ApiException;

import java.security.SecureRandom;
import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.CompletableFuture;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@SpringBootApplication
public class Main {
  // The environment variable containing a Square Personal Access Token.
  // This must be set in order for the application to start.
  private static final String SQUARE_ACCESS_TOKEN_ENV_VAR = "SQUARE_ACCESS_TOKEN";

  // The environment variable containing a Square application ID.
  // This must be set in order for the application to start.
  private static final String SQUARE_APP_ID_ENV_VAR = "SQUARE_APPLICATION_ID";

  // The environment variable containing a Square location ID.
  // This must be set in order for the application to start.
  private static final String SQUARE_LOCATION_ID_ENV_VAR = "SQUARE_LOCATION_ID";

  // The environment variable indicate the square environment - sandbox or
  // production.
  // This must be set in order for the application to start.
  private static final String SQUARE_ENV_ENV_VAR = "ENVIRONMENT";

  private final SquareClient squareClient;
  private final String squareLocationId;
  private final String squareAppId;
  private final String squareEnvironment;

  public Main() throws ApiException {
    squareEnvironment = mustLoadEnvironmentVariable(SQUARE_ENV_ENV_VAR);
    squareAppId = mustLoadEnvironmentVariable(SQUARE_APP_ID_ENV_VAR);
    squareLocationId = mustLoadEnvironmentVariable(SQUARE_LOCATION_ID_ENV_VAR);

    squareClient = new SquareClient.Builder()
        .environment(Environment.fromString(squareEnvironment))
        .accessToken(mustLoadEnvironmentVariable(SQUARE_ACCESS_TOKEN_ENV_VAR)).build();
  }

  public static void main(String[] args) throws Exception {
    SpringApplication.run(Main.class, args);
  }

  private String mustLoadEnvironmentVariable(String name) {
    String value = System.getenv(name);
    if (value == null || value.length() == 0) {
      throw new IllegalStateException(
          String.format("The %s environment variable must be set", name));
    }

    return value;
  }

  @PostMapping("/walletTopUp")
  public @ResponseBody Payment chargeTopUp(@RequestBody WalletTopUpWrapper body)
          throws Exception {
    final String currency = getLocationInformation(squareClient)
            .get()
            .getLocation()
            .getCurrency();
    final Money amountMoney = new Money.Builder()
            .amount(body.getAmount())
            .currency(currency)
            .build();
    final OrderLineItem lineItem = new OrderLineItem.Builder("1")
            .name(body.getName())
            .basePriceMoney(amountMoney)
            .build();
    final String locationID = squareClient.getLocationsApi()
            .listLocations()
            .getLocations()
            .get(0)
            .getId();
    final List<OrderLineItem> lineItems = new LinkedList<>();
    lineItems.add(lineItem);
    Order bodyOrder = new Order.Builder(locationID)
            .lineItems(lineItems)
            .build();
    CreateOrderRequest orderRequest = new CreateOrderRequest.Builder()
            .order(bodyOrder)
            .idempotencyKey(UUID.randomUUID().toString())
            .build();
    System.out.println("Creating order");

    return squareClient.getOrdersApi()
            .createOrderAsync(orderRequest)
            .thenApply(createOrderResponse -> {
              System.out.println("order response");
              System.out.println(createOrderResponse.getOrder().getId());
              final CreatePaymentRequest createPaymentRequest = new CreatePaymentRequest.Builder(
                      body.getNonce(),
                      UUID.randomUUID().toString(),
                      createOrderResponse.getOrder().getTotalMoney())
                      .orderId(createOrderResponse.getOrder().getId())
                      .autocomplete(true)
                      .build();
              return squareClient.getPaymentsApi()
                      .createPaymentAsync(createPaymentRequest)
                      .thenApply(createPaymentResponse -> {
                        System.out.println("Returning response");
                        return createPaymentResponse.getPayment();
                      }).join();
            }).join();
  }

  @PostMapping("/chargeForCookie")
  @ResponseBody PaymentResult chargeCookie(@RequestBody Map<String, Object> model)
          throws Exception {
    RetrieveLocationResponse locationResponse = getLocationInformation(squareClient).get();
    String currency = locationResponse.getLocation().getCurrency();

    Money bodyAmountMoney = new Money.Builder()
            .amount(100L)
            .currency("IDR")
            .build();

    OrderLineItem lineItem = new OrderLineItem.Builder("1")
            .name("Cookie")
            .basePriceMoney(bodyAmountMoney)
            .build();

    List<OrderLineItem> bodyOrderLineItems = new LinkedList<>();
    bodyOrderLineItems.add(lineItem);

    // https://github.com/square/square-java-sdk/blob/master/doc/api/orders.md#create-order
    Order bodyOrder = new Order.Builder(
            squareClient.getLocationsApi().listLocations().getLocations().get(0).getId()
    )
            .lineItems(bodyOrderLineItems)
            .build();

    SecureRandom rnd = new SecureRandom();
    byte[] bys = new byte[12];
    rnd.nextBytes(bys);

    CreateOrderRequest body = new CreateOrderRequest.Builder()
            .order(bodyOrder)
            .idempotencyKey(UUID.randomUUID().toString())
            .build();

    final String nonce = (String) model.get("nonce");

    squareClient.getOrdersApi().createOrderAsync(body).thenAccept(result -> {
//      System.out.println(result);

      SecureRandom random = new SecureRandom();
      byte[] bytes = new byte[12];
      random.nextBytes(bytes);


      CreatePaymentRequest createPaymentRequest = new CreatePaymentRequest.Builder(
              nonce,
              UUID.randomUUID().toString(),
              result.getOrder().getTotalMoney()
      )
              .orderId(result.getOrder().getId())
              .autocomplete(true)
              .build();

      squareClient.getPaymentsApi().createPaymentAsync(createPaymentRequest)
              .thenApply( r -> {

                r.getPayment();
                return new PaymentResult("SUCCESS", null);
              })
              .exceptionally(exception -> {
//                System.out.println(exception);

                ApiException e = (ApiException) exception.getCause();
                System.out.println("Failed to make the request");
                System.out.printf("Exception: %s%n", e.getMessage());
                System.out.println(e.getErrors());
                System.out.println(e.getResponseCode());
                return new PaymentResult("FAILURE", e.getErrors());
      });

    }).exceptionally(e -> null);

    return null;
  }

  @PostMapping("/process-payment")
  @ResponseBody PaymentResult processPayment(@RequestBody TokenWrapper tokenObject)
      throws InterruptedException, ExecutionException {
    // To learn more about splitting payments with additional recipients,
    // see the Payments API documentation on our [developer site]
    // (https://developer.squareup.com/docs/payments-api/overview).

    // Get currency for location
    RetrieveLocationResponse locationResponse = getLocationInformation(squareClient).get();
    String currency = locationResponse.getLocation().getCurrency();

    Money bodyAmountMoney = new Money.Builder()
        .amount(100L)
        .currency(currency)
        .build();

    CreatePaymentRequest createPaymentRequest = new CreatePaymentRequest.Builder(
        tokenObject.getToken(),
        UUID.randomUUID().toString(),
        bodyAmountMoney)
        .build();

    PaymentsApi paymentsApi = squareClient.getPaymentsApi();
    return paymentsApi.createPaymentAsync(createPaymentRequest).thenApply(result -> {
      return new PaymentResult("SUCCESS", null);
    }).exceptionally(exception -> {
      ApiException e = (ApiException) exception.getCause();
      System.out.println("Failed to make the request");
      System.out.printf("Exception: %s%n", e.getMessage());
      return new PaymentResult("FAILURE", e.getErrors());
    }).join();
  }

  /**
   * Helper method that makes a retrieveLocation API call using the configured locationId and
   * returns the future containing the response
   *
   * @param squareClient the API client
   * @return a future that holds the retrieveLocation response
   */
  private CompletableFuture<RetrieveLocationResponse> getLocationInformation(
      SquareClient squareClient) {
    return squareClient.getLocationsApi().retrieveLocationAsync(squareLocationId)
        .thenApply(result -> {
          return result;
        })
        .exceptionally(exception -> {
          System.out.println("Failed to make the request");
          System.out.printf("Exception: %s%n", exception.getMessage());
          return null;
        });
  }
}