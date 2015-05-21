import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamSource
import javax.xml.transform.stream.StreamResult
import java.io.File
import java.io.FileFilter
import java.io.PrintWriter
import scala.collection.mutable
import java.text.SimpleDateFormat
import java.util.Calendar
import javax.xml.transform.OutputKeys

def time = Calendar.getInstance().getTime().getTime()

def timeFormattedString(t: Long) = (new SimpleDateFormat("hh:mm:sss")).format(t)

def printToFile(f: java.io.File)(op: java.io.PrintWriter => Unit) {
  val p = new java.io.PrintWriter(f)
  try { op(p) } finally { p.close() }
}

val errorFiles = new mutable.ListBuffer[String];

def transform(dataXML: String, inputXSL: String, outputHTML: String, index: Int, totalFiles: Int) = {
  try {
    val factory = TransformerFactory.newInstance();
    val xslStream = new StreamSource(inputXSL);
    val transformer = factory.newTransformer(xslStream);
    transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
    transformer.setOutputProperty(OutputKeys.INDENT, "yes");

    val inFile = new File(dataXML);
    val in = new StreamSource(inFile);
    val out = new StreamResult(outputHTML);
    transformer.transform(in, out);
    System.out.println("[" + index + "/" + totalFiles + " The generated XML file is:" + outputHTML);
  } catch {
    case e: Exception => {
      println(e);
      errorFiles += dataXML;
    }
  }
}

// ---- MAIN ----
val start = time

// EXAMPLE createSolrDocs.sh data/downloaded/ data/solr_docs ../../test/chp03/dbpedia_start/dbpediaToPost.xslt 
val rdfDir = new File(args { 0 }).getCanonicalFile()
val outDir = new File(args { 1 }).getCanonicalFile()
if (!outDir.exists()) outDir.mkdirs()
val xslt = args { 2 }

// if the directory containing RDF is wrong or does not exists, throw an exception
if (!rdfDir.exists()) throw new RuntimeException(rdfDir + " does not exists!")

val files = rdfDir.listFiles(new FileFilter() {
  override def accept(pathname: File): Boolean = {
    pathname.getName().endsWith(".rdf.xml")
  }
}).toList

val totalFiles = files.length;

files.zipWithIndex.foreach{case (f, index) => {
  transform(f.getAbsolutePath(), xslt, new File(outDir, f.getName().replaceAll("\\.rdf\\.", "\\.post\\.")).getAbsolutePath(), index, totalFiles);
}};

// print error files
// val data = Array("Five","strings","in","a","file!")
// printToFile(new File("example.txt")) { p =>
//   data.foreach(p.println)
// }
println("---> Number of error files = " + errorFiles.length)
printToFile(new File("error.txt")) { p =>
  errorFiles.foreach(p.println)
}

val end = (time - start) / 1000.0
printf("Create Solr %s docs completed (TIME: %s seconds)\n", totalFiles, end)