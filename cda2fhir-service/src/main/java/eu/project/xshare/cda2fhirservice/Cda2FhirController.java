package eu.project.xshare.cda2fhirservice;

import eu.project.xshare.cda2fhirlib.Cda2FhirTransformer;
import eu.project.xshare.cda2fhirlib.InvalidCdaException;
import eu.project.xshare.cda2fhirlib.TransformationException;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Cda2FhirController {

  private final Cda2FhirTransformer transformer;

  public Cda2FhirController(Cda2FhirTransformer transformer) {
    this.transformer = transformer;
  }

  @PostMapping(value = "/transform", consumes = "application/xml", produces = "application/json")
  public String transformCdaToFhir(@RequestBody @NotBlank String cda) {
    return transformer.transformCdaToIps(cda);
  }

  @ResponseStatus(HttpStatus.BAD_REQUEST)
  @ExceptionHandler(InvalidCdaException.class)
  public ProblemDetail handleInvalidCdaException(InvalidCdaException e) {
    return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, e.getMessage());
  }

  @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
  @ExceptionHandler(TransformationException.class)
  public ProblemDetail handleTransformationException(TransformationException e) {
    return ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
  }
}
