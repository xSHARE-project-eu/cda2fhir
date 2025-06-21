package eu.project.xshare.cda2fhirlib;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.parser.IParser;
import freemarker.template.Configuration;
import freemarker.template.Template;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.Callable;
import lombok.SneakyThrows;
import org.hl7.fhir.instance.model.api.IBaseBundle;
import org.hl7.fhir.r4.model.Bundle;
import org.hl7.fhir.r4.model.Resource;
import org.openhealthtools.mdht.uml.cda.consol.ConsolPackage;
import org.openhealthtools.mdht.uml.cda.consol.ContinuityOfCareDocument;
import org.openhealthtools.mdht.uml.cda.util.CDAUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The Cda2FhirTransformer class is responsible for transforming Clinical Document Architecture
 * (CDA) documents into Fast Healthcare Interoperability Resources (FHIR) International Patient
 * Summary (IPS) format.
 *
 * <p>This transformer uses Freemarker templates to process CDA documents and convert them into FHIR
 * JSON format. It extracts relevant information from the CDA document such as patient details,
 * organization information, and practitioner data, and maps them to the corresponding FHIR
 * resources.
 *
 * <p>The transformation process involves parsing the CDA document, extracting necessary data,
 * applying Freemarker templates, and generating a properly formatted FHIR JSON output.
 */
public class Cda2FhirTransformer {

  private static final Logger log = LoggerFactory.getLogger(Cda2FhirTransformer.class);

  private final Configuration freemarkerConfig;

  private final FhirContext fhirContext = FhirContext.forR4Cached();

  /**
   * Constructs a new Cda2FhirTransformer with the default Freemarker configuration.
   *
   * <p>This constructor uses the default configuration provided by the FreemarkerConfigFactory.
   */
  public Cda2FhirTransformer() {
    this(FreemarkerConfigFactory.defaultConfiguration());
  }

  /**
   * Constructs a new Cda2FhirTransformer with a custom Freemarker configuration.
   *
   * <p>This constructor allows for customization of the Freemarker configuration used for template
   * processing during the transformation.
   *
   * @param freemarkerConfig the Freemarker configuration to use for template processing
   */
  public Cda2FhirTransformer(Configuration freemarkerConfig) {
    this.freemarkerConfig = freemarkerConfig;
  }

  /**
   * Transforms a CDA XML string into a FHIR IPS JSON string.
   *
   * <p>This method takes a CDA document as an XML string, parses it into a
   * ContinuityOfCareDocument, and then transforms it into a FHIR IPS JSON string using Freemarker
   * templates.
   *
   * @param cdaString the CDA XML string to transform
   * @return a formatted JSON string representing the FHIR IPS
   * @throws TransformationException if there is an error during the JSON processing
   * @throws InvalidCdaException if the input string is not a valid CDA document
   */
  public String transformCdaToIps(String cdaString) {
    return transformCdaToIps(parseXmlToCda(cdaString));
  }

  public String transformCdaToIps(InputStream cdaStream) {
    return transformCdaToIps(parseXmlToCda(cdaStream));
  }

  /**
   * Transforms a ContinuityOfCareDocument object into a FHIR IPS JSON string.
   *
   * <p>This method takes a pre-parsed CDA document as input and transforms it into a FHIR IPS JSON
   * string using Freemarker templates.
   *
   * @param cda the ContinuityOfCareDocument to transform
   * @return a formatted JSON string representing the FHIR IPS
   * @throws TransformationException if there is an error during the transformation process
   */
  public String transformCdaToIps(ContinuityOfCareDocument cda) {
    try {
      String mxdeString = mxdeTransform(cda);
      IParser jsonParser = fhirContext.newJsonParser();
      Bundle mxdeBundle = jsonParser.parseResource(Bundle.class, mxdeString);

      MyIpsGenerator myIpsGenerator = new MyIpsGenerator(fhirContext, mxdeBundle);
      IBaseBundle ipsBundle = myIpsGenerator.generateIps();

      return jsonParser.encodeResourceToString(ipsBundle);
    } catch (Exception e) {
      throw new TransformationException(e.getMessage(), e);
    }
  }

  public String mxdeTransform(InputStream cdaStream) {
    return mxdeTransform(parseXmlToCda(cdaStream));
  }

  public String mxdeTransform(String cdaString) {
    return mxdeTransform(parseXmlToCda(cdaString));
  }

  public String mxdeTransform(ContinuityOfCareDocument cda) {
    try {
      String fhirBundleString = transform(cda);
      Bundle fhirBundle = parseJsonToBundle(fhirBundleString);
      String provenanceString = constructProvenance(fhirBundle);

      Map<String, Object> dataModel = new HashMap<>();
      dataModel.put("entries", getEntries(fhirBundle));
      dataModel.put("provenance", provenanceString);

      Template template = freemarkerConfig.getTemplate("mxde_bundle.ftl");
      StringWriter writer = new StringWriter();
      template.process(dataModel, writer);
      String mxdeBundleJson = writer.toString();

      // Validate JSON
      IParser fhirJsonParser = fhirContext.newJsonParser();
      Bundle mxdeBundle = fhirJsonParser.parseResource(Bundle.class, mxdeBundleJson);

      return fhirJsonParser.encodeResourceToString(mxdeBundle);
    } catch (Exception e) {
      throw new TransformationException(e.getMessage(), e);
    }
  }

  /**
   * Core transformation method that converts a CDA document to a FHIR JSON string.
   *
   * <p>This method prepares a data model with the CDA document and additional information, then
   * processes it through a Freemarker template to generate the FHIR JSON output.
   *
   * @param cda the ContinuityOfCareDocument to transform
   * @return a JSON string representing the FHIR bundle
   * @throws InvalidCdaException if there is an error processing the CDA document
   * @throws TransformationException if there is an error during the transformation process
   */
  @SneakyThrows
  private String transform(ContinuityOfCareDocument cda) {
    if (log.isDebugEnabled()) {
      ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
      CDAUtil.save(cda, byteArrayOutputStream);
      log.debug("Incoming CDA:{}", byteArrayOutputStream.toString(StandardCharsets.UTF_8));
    }

    Map<String, Object> dataModel = new HashMap<>();
    dataModel.put("cda", cda);
    dataModel.put("patientUuid", generatePatientUuid());
    dataModel.put("practitionerUuid", generatePatientUuid());

    addPatientAddress(dataModel, cda);
    addOrganizationAddress(dataModel, cda);
    addPractitionerAddress(dataModel, cda);

    Template template = freemarkerConfig.getTemplate("fhir_bundle.ftl");
    StringWriter writer = new StringWriter();
    template.process(dataModel, writer);

    return writer.toString();
  }

  private String constructProvenance(Bundle fhirBundle) throws Exception {
    Map<String, Object> dataModel = new HashMap<>();
    dataModel.put("fhirBundle", fhirBundle);

    Template template = freemarkerConfig.getTemplate("provenance.ftl");
    StringWriter writer = new StringWriter();
    template.process(dataModel, writer);

    return writer.toString();
  }

  /**
   * Generates a random UUID for the patient.
   *
   * <p>This method creates a unique identifier for the patient in the FHIR bundle.
   *
   * @return a string representation of a random UUID
   */
  private String generatePatientUuid() {
    return UUID.randomUUID().toString();
  }

  private List<Map<String, Object>> getEntries(Bundle fhirBundle) {
    IParser jsonParser = fhirContext.newJsonParser();

    List<Map<String, Object>> resourceEntries = new ArrayList<>();

    for (Bundle.BundleEntryComponent entry : fhirBundle.getEntry()) {
      Resource resource = entry.getResource();

      String resourceJson = jsonParser.encodeResourceToString(resource);

      Map<String, Object> resourceEntry = new LinkedHashMap<>();
      resourceEntry.put("fullUrl", entry.getFullUrl());
      resourceEntry.put("resource", resourceJson);
      resourceEntry.put("request", Map.of("url", resource.getResourceType().name()));

      resourceEntries.add(resourceEntry);
    }

    return resourceEntries;
  }

  /**
   * Extracts patient address information from the CDA document and adds it to the data model.
   *
   * <p>This method safely extracts the patient's telecom, street address, city, postal code, and
   * country from the CDA document and adds them to the data model for use in the FHIR
   * transformation templates.
   *
   * @param dataModel the data model to populate with patient address information
   * @param cda the CDA document containing the patient information
   */
  private void addPatientAddress(Map<String, Object> dataModel, ContinuityOfCareDocument cda) {
    String telecom =
        safeGet(
            () ->
                cda.getRecordTargets()
                    .getFirst()
                    .getPatientRole()
                    .getTelecoms()
                    .getFirst()
                    .getValue());
    String street =
        (String)
            safeGet(
                () ->
                    cda.getRecordTargets()
                        .getFirst()
                        .getPatientRole()
                        .getAddrs()
                        .getFirst()
                        .getStreetAddressLines()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());
    String city =
        (String)
            safeGet(
                () ->
                    cda.getRecordTargets()
                        .getFirst()
                        .getPatientRole()
                        .getAddrs()
                        .getFirst()
                        .getCities()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    String postalCode =
        (String)
            safeGet(
                () ->
                    cda.getRecordTargets()
                        .getFirst()
                        .getPatientRole()
                        .getAddrs()
                        .getFirst()
                        .getPostalCodes()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());
    String country =
        (String)
            safeGet(
                () ->
                    cda.getRecordTargets()
                        .getFirst()
                        .getPatientRole()
                        .getAddrs()
                        .getFirst()
                        .getCountries()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    dataModel.put("telecomPatient", telecom);
    dataModel.put("addr", street);
    dataModel.put("city", city);
    dataModel.put("postalCode", postalCode);
    dataModel.put("country", country);
  }

  /**
   * Extracts organization address information from the CDA document and adds it to the data model.
   *
   * <p>This method safely extracts the organization's telecom, street address, city, and postal
   * code from the CDA document and adds them to the data model for use in the FHIR transformation
   * templates.
   *
   * <p>Note that the postal code is extracted from the patient's address rather than the
   * organization's address.
   *
   * @param dataModel the data model to populate with organization address information
   * @param cda the CDA document containing the organization information
   */
  private void addOrganizationAddress(Map<String, Object> dataModel, ContinuityOfCareDocument cda) {
    String telecom =
        safeGet(
            () ->
                cda.getCustodian()
                    .getAssignedCustodian()
                    .getRepresentedCustodianOrganization()
                    .getTelecom()
                    .getValue());

    String street =
        (String)
            safeGet(
                () ->
                    cda.getCustodian()
                        .getAssignedCustodian()
                        .getRepresentedCustodianOrganization()
                        .getAddrs()
                        .getFirst()
                        .getStreetAddressLines()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());
    String city =
        (String)
            safeGet(
                () ->
                    cda.getCustodian()
                        .getAssignedCustodian()
                        .getRepresentedCustodianOrganization()
                        .getAddrs()
                        .getFirst()
                        .getCities()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    String postalCode =
        (String)
            safeGet(
                () ->
                    cda.getRecordTargets()
                        .getFirst()
                        .getPatientRole()
                        .getAddrs()
                        .getFirst()
                        .getPostalCodes()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    dataModel.put("telecomOrg", telecom);
    dataModel.put("streetOrg", street);
    dataModel.put("cityOrg", city);
    dataModel.put("postalCodeOrg", postalCode);
  }

  /**
   * Extracts practitioner address information from the CDA document and adds it to the data model.
   *
   * <p>This method safely extracts the practitioner's street address, city, and postal code from
   * the legal authenticator in the CDA document and adds them to the data model for use in the FHIR
   * transformation templates.
   *
   * @param dataModel the data model to populate with practitioner address information
   * @param cda the CDA document containing the practitioner information
   */
  private void addPractitionerAddress(Map<String, Object> dataModel, ContinuityOfCareDocument cda) {
    String streetOrg =
        (String)
            safeGet(
                () ->
                    cda.getLegalAuthenticator()
                        .getAssignedEntity()
                        .getAddrs()
                        .getFirst()
                        .getStreetAddressLines()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    String cityOrg =
        (String)
            safeGet(
                () ->
                    cda.getLegalAuthenticator()
                        .getAssignedEntity()
                        .getAddrs()
                        .getFirst()
                        .getCities()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());
    String postalCodeOrg =
        (String)
            safeGet(
                () ->
                    cda.getLegalAuthenticator()
                        .getAssignedEntity()
                        .getAddrs()
                        .getFirst()
                        .getPostalCodes()
                        .getFirst()
                        .getMixed()
                        .getFirst()
                        .getValue());

    dataModel.put("practitionerStreet", streetOrg);
    dataModel.put("practitionerCity", cityOrg);
    dataModel.put("practitionerPostalCode", postalCodeOrg);
  }

  /**
   * Safely retrieves a value using a provided getter function.
   *
   * <p>This utility method attempts to retrieve a value using the provided getter function. If the
   * getter function throws an exception (e.g., due to a null reference in the chain), the method
   * logs the error and returns null instead of propagating the exception.
   *
   * @param <T> the type of the value to retrieve
   * @param getter a Callable that retrieves the desired value
   * @return the retrieved value, or null if an exception occurred
   */
  private static <T> T safeGet(Callable<T> getter) {
    try {
      return getter.call();
    } catch (Exception e) {
      log.debug("Failed to get value from getter", e);

      return null;
    }
  }

  private Bundle parseJsonToBundle(String jsonString) {
    FhirContext fhirContext = FhirContext.forR4Cached();
    IParser jsonParser = fhirContext.newJsonParser();

    return jsonParser.parseResource(Bundle.class, jsonString);
  }

  private ContinuityOfCareDocument parseXmlToCda(InputStream xmlStream) {
    try {
      return (ContinuityOfCareDocument)
          CDAUtil.loadAs(xmlStream, ConsolPackage.eINSTANCE.getContinuityOfCareDocument());
    } catch (Exception e) {
      throw new InvalidCdaException(e.getMessage(), e);
    }
  }

  private ContinuityOfCareDocument parseXmlToCda(String xmlString) {
    try {
      InputStream inputStream =
          new ByteArrayInputStream(xmlString.getBytes(StandardCharsets.UTF_8));

      return (ContinuityOfCareDocument)
          CDAUtil.loadAs(inputStream, ConsolPackage.eINSTANCE.getContinuityOfCareDocument());
    } catch (Exception e) {
      throw new InvalidCdaException(e.getMessage(), e);
    }
  }
}
