from rdflib import Graph

g = Graph()
owl_file_path = "./Rdev/onto/data/OntPreHer3D_v1.owl"

try:
    g.parse(owl_file_path, format="xml")  # Attempt parsing as RDF/XML (default OWL format)
    validation_result = "✅ The OWL file is well-formed and correctly structured."
except Exception as e:
    validation_result = f"❌ There is an error in the OWL file: {str(e)}"

# Display the validation result
print(validation_result)
