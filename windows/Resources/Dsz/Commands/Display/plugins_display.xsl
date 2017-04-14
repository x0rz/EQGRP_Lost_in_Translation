<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:param name="verbose" select="'false'"/>
	
    <xsl:template match="Plugins">
		<xsl:apply-templates select="Local"/>
		<xsl:apply-templates select="Remote"/>
	</xsl:template>
	
	<xsl:template match="Local">
		<xsl:text>The following plugins are currently loaded LOCALLY (</xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    ID      COUNT      PLUGINNAME                            LOADER_INFO</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="$verbose != 'true'">
			<xsl:text>----------------------------------------------------------------------------</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:apply-templates select="Plugin"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Remote">
		<xsl:text>The following plugins are currently loaded REMOTELY (</xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>  ID  COUNT    PLUGINNAME                          LOADER_INFO</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="$verbose != 'true'">
			<xsl:text>----------------------------------------------------------------------------</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:apply-templates select="Plugin"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Plugin">
		<xsl:if test="($verbose = 'true') or not(Core)">
		<xsl:if test="$verbose = 'true'">
			<xsl:text>----------------------------------------------------------------------------</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="6 - string-length(@id)"/>
		</xsl:call-template>
		<xsl:value-of select="@id"/>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4"/>
		</xsl:call-template>

		<xsl:value-of select="@loadCount"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5"/>
		</xsl:call-template>

		<xsl:value-of select="@name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="VersionInformation/ModuleVersion/@major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="VersionInformation/ModuleVersion/@minor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="VersionInformation/ModuleVersion/@revision"/>
		<xsl:text>)</xsl:text>
			
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="30-string-length(@name)"/>
		</xsl:call-template>

		<xsl:call-template name="PrintNameFromPath">
			<xsl:with-param name="path" select="@loaderInfo"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="NotLoaded">
			<xsl:text>ERROR - NOT REALLY LOADED!</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="$verbose = 'true'">
			<xsl:text>      Type : </xsl:text>
			<xsl:choose>
				<xsl:when test="Core">
					<xsl:text>CORE</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>NON-CORE</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:if test="@realId">
				<xsl:text>   Real Id : </xsl:text>
				<xsl:value-of select="@realId"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:apply-templates select="Registered"/>
			<xsl:apply-templates select="Acquired"/>
			
			<xsl:text>      File : </xsl:text>
			<xsl:value-of select="@loaderInfo"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:apply-templates select="Dependancy"/>
		</xsl:if>
	</xsl:template>
    
    <xsl:template match="Registered">
		<xsl:text>  Registered APIs : </xsl:text>
		<xsl:value-of select="substring-before(., '.')"/>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>
	<xsl:template match="Acquired">
		<xsl:text>    Acquired APIs : </xsl:text>
		<xsl:value-of select="substring-before(., '.')"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@module"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>
    
    <xsl:template match="Dependancy">
		<xsl:text>        DEPENDS ON </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

</xsl:transform>