package eu.project.xshare.cda2fhirlib;

import java.util.UUID;

public class UuidGenerator {

  public String generate() {
    return UUID.randomUUID().toString();
  }
}
