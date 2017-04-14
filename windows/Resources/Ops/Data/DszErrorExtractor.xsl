<?xml version='1.1' encoding="UTF-8" ?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:MCA='urn:mca:db00db84-8b5b-2141-a632b5980175d3c6'>
    
    <xsl:output method="xml" />
    
    <xsl:template match="/">
        <xsl:element name="Errors">
            <xsl:attribute name="timestamp">
                <xsl:value-of select="MCA:DataLog/MCA:CommandData/MCA:Errors/@dataTimestamp" />
            </xsl:attribute>
            <xsl:for-each select="MCA:DataLog/MCA:CommandData/MCA:Errors/*">
                <xsl:element name="Error">
                    <xsl:attribute name="type">
                        <xsl:value-of select="name(.)" />
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
