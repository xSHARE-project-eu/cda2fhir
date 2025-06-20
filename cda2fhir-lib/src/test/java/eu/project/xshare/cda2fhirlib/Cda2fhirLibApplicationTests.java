package eu.project.xshare.cda2fhirlib;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.FileInputStream;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.openhealthtools.mdht.uml.cda.consol.ConsolPackage;
import org.openhealthtools.mdht.uml.cda.consol.ContinuityOfCareDocument;
import org.openhealthtools.mdht.uml.cda.util.CDAUtil;

class Cda2fhirLibApplicationTests {

  @Test
  void testCda2fhirLib() throws Exception {

    String filePath = "src/test/resources/cda/cda-eumfh-43-155-ips.xml";
    FileInputStream fis = new FileInputStream(filePath);
    ContinuityOfCareDocument cda =
        (ContinuityOfCareDocument)
            CDAUtil.loadAs(fis, ConsolPackage.eINSTANCE.getContinuityOfCareDocument());

    Cda2FhirTransformer transformer = new Cda2FhirTransformer();
    String result = transformer.transformCdaToIps(cda);

    Assertions.assertNotNull(fis);
    Assertions.assertNotNull(result);

    System.out.println(result);
  }


  @Test
  void testMxde() throws Exception {
    ObjectMapper objectMapper = new ObjectMapper();

    String filePath = "src/test/resources/cda/cda-eumfh-43-155-ips.xml";
    FileInputStream fis = new FileInputStream(filePath);
    ContinuityOfCareDocument cda =
        (ContinuityOfCareDocument)
            CDAUtil.loadAs(fis, ConsolPackage.eINSTANCE.getContinuityOfCareDocument());

    Cda2FhirTransformer transformer = new Cda2FhirTransformer();
    String result = transformer.mxdeTransform(cda);
    Assertions.assertNotNull(result);

    Object json = objectMapper.readValue(result, Object.class);
    String prettyJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(json);

    Assertions.assertNotNull(prettyJson);

    System.out.println(prettyJson);
  }
}
