package eu.project.xshare.cda2fhirlib;

public class InvalidCdaException extends RuntimeException {

  public InvalidCdaException(String message) {
    super(message);
  }

  public InvalidCdaException(String message, Throwable cause) {
    super(message, cause);
  }
}
