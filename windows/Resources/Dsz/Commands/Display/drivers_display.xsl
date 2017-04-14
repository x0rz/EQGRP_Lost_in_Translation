<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>
  
	<xsl:template match="Drivers">
		<xsl:apply-templates select="Driver"/>
	</xsl:template>
	
	<xsl:template match="Driver">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>          Name : </xsl:text>
				<xsl:value-of select="Name" />
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>        Signed : </xsl:text>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:choose>
			<xsl:when test="Signed">
				<xsl:call-template name="XmlOutput">
					<xsl:with-param name="type" select="'Good'"/>
					<xsl:with-param name="text">
						<xsl:text>YES</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="Unsigned">
				<xsl:call-template name="XmlOutput">
					<xsl:with-param name="type" select="'Error'"/>
					<xsl:with-param name="text">
						<xsl:text>NO</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="XmlOutput">
					<xsl:with-param name="type" select="'Warning'"/>
					<xsl:with-param name="text">
						<xsl:text>UNKNOWN</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>

		<xsl:if test="string-length(Author) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>        Author : </xsl:text>
					<xsl:value-of select="Author" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
        
        <xsl:if test="string-length(License) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>       License : </xsl:text>
					<xsl:value-of select="License" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="string-length(Version) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>       Version : </xsl:text>
					<xsl:value-of select="Version" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="string-length(Description) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>   Description : </xsl:text>
					<xsl:value-of select="Description" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="string-length(FilePath) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>      FilePath : </xsl:text>
					<xsl:value-of select="FilePath" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="BuildDate">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>    Build Date : </xsl:text>
					<xsl:value-of select="substring-before(BuildDate, 'T')"/>
   					<xsl:text> </xsl:text>
		   			<xsl:value-of select="substring-before(substring-after(BuildDate, 'T'), '.')"/>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="string-length(Comments) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>      Comments : </xsl:text>
					<xsl:value-of select="Comments" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="string-length(InternalName) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text> Internal Name : </xsl:text>
					<xsl:value-of select="InternalName" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="string-length(OriginalName) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text> Original Name : </xsl:text>
					<xsl:value-of select="OriginalName" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="string-length(ProductName) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>  Product Name : </xsl:text>
					<xsl:value-of select="ProductName" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="string-length(Trademark) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>     Trademark : </xsl:text>
					<xsl:value-of select="Trademark" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>          Size : </xsl:text>
				<xsl:value-of select="@size" />
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>     LoadCount : </xsl:text>
				<xsl:value-of select="@loadCount" />
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>    Image Base : </xsl:text>
				<xsl:value-of select="@base" />
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>         Flags : </xsl:text>
				<xsl:value-of select="@flags" />
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>

		<xsl:if test="string-length(UsedByModules) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text> UsedByModules : </xsl:text>
					<xsl:value-of select="UsedByModules" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test="string-length(Dependencies) &gt; 0">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Default'"/>
				<xsl:with-param name="text">
					<xsl:text>  Dependencies : </xsl:text>
					<xsl:value-of select="Dependencies" />
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<!--
		<xsl:if test="string-length(Alias) &gt; 0">
			<xsl:text>         Alias : </xsl:text>
			<xsl:value-of select="Alias" />
			<xsl:call-template name="PrintReturn" />
		</xsl:if>

		<xsl:if test="string-length(LoadParameters) &gt; 0">
			<xsl:text>LoadParameters : </xsl:text>
			<xsl:value-of select="LoadParameters" />
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		-->
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>-----------------------------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Success">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>The operation completed successfully</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>
