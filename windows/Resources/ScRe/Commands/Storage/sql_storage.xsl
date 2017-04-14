<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:element name="StorageObjects">
	  <xsl:apply-templates select="Sql"/>
	  <xsl:apply-templates select="Drivers"/>
      <xsl:apply-templates select="Sources"/>
      <xsl:apply-templates select="Servers"/>
      <xsl:apply-templates select="Tables"/>
      <xsl:apply-templates select="Columns"/>
      <xsl:apply-templates select="Query"/>
      <xsl:apply-templates select="Error"/>
      <xsl:apply-templates select="CommandInfo"/>
	  <xsl:apply-templates select="UncompressedData"/>
	  <xsl:apply-templates select="Connect"/>
	  <xsl:apply-templates select="Handles"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Error">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">SqlErrorItem</xsl:attribute>

      <xsl:element name="IntValue">
        <xsl:attribute name="name">ErrorCode</xsl:attribute>
        <xsl:value-of select="ErrorCode"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">SqlState</xsl:attribute>
        <xsl:value-of select="SqlState"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Message</xsl:attribute>
        <xsl:value-of select="Message"/>
      </xsl:element>

    </xsl:element>
  </xsl:template>
  
  <xsl:template match="CommandInfo">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">CommandInfo</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Action</xsl:attribute>
        <xsl:value-of select="Action"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">TableName</xsl:attribute>
        <xsl:value-of select="TableName"/>
      </xsl:element>
      
      <xsl:element name="StringValue">
        <xsl:attribute name="name">QueryString</xsl:attribute>
        <xsl:value-of select="QueryString"/>
      </xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">File</xsl:attribute>
				<xsl:value-of select="File"/>
			</xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">ConnectionString</xsl:attribute>
        <xsl:value-of select="ConnectionString"/>
      </xsl:element>

	  <xsl:element name="StringValue">
		<xsl:attribute name="name">AccessString</xsl:attribute>
		<xsl:value-of select="AccessType"/>
	  </xsl:element>
	  
	  <xsl:element name="IntValue">
		<xsl:attribute name="name">HandleId</xsl:attribute>
		<xsl:value-of select="HandleId"/>
	  </xsl:element>
	  
	  <xsl:element name="IntValue">
		<xsl:attribute name="name">MaxColumnSize</xsl:attribute>
		<xsl:value-of select="MaxColumnSize"/>
	  </xsl:element>

      <xsl:element name="BoolValue">
        <xsl:attribute name="name">ConsoleOutput</xsl:attribute>
		  <xsl:text>true</xsl:text>
      </xsl:element>

    </xsl:element>
  </xsl:template>

	<xsl:template match="Sql">
		<xsl:apply-templates/>
	</xsl:template>
	
  <xsl:template match="Drivers">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">DriversItem</xsl:attribute>
      <xsl:apply-templates select="Driver"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Driver">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">DriverItem</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Name</xsl:attribute>
        <xsl:value-of select="Name"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Attributes</xsl:attribute>
        <xsl:value-of select="Attributes"/>
      </xsl:element>

      <xsl:apply-templates select="Warning"/>

    </xsl:element>
  </xsl:template>

  <xsl:template match="Warning">
    <xsl:element name="StringValue">
      <xsl:attribute name="name">Warning</xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Sources">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">SourcesItem</xsl:attribute>
      <xsl:apply-templates select="DataSource"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="DataSource">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">SourceItem</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Name</xsl:attribute>
        <xsl:value-of select="Name"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Description</xsl:attribute>
        <xsl:value-of select="Description"/>
      </xsl:element>

    </xsl:element>
  </xsl:template>



  <xsl:template match="Servers">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">ServersItem</xsl:attribute>
      <xsl:apply-templates select="Server"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Server">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">ServerItem</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Name</xsl:attribute>
        <xsl:value-of select="."/>
      </xsl:element>

    </xsl:element>
  </xsl:template>

  <xsl:template match="ColumnInfo">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">ColumnInfoItem</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">TotalColumns</xsl:attribute>
        <xsl:value-of select="TotalColumns"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">StartRow</xsl:attribute>
        <xsl:value-of select="StartRow"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">EndRow</xsl:attribute>
        <xsl:value-of select="EndRow"/>
      </xsl:element>

      <xsl:apply-templates select="Column"/>
      
    </xsl:element>
  </xsl:template>

  <xsl:template match="Column">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">ColumnItem</xsl:attribute>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">Name</xsl:attribute>
        <xsl:value-of select="Name"/>
      </xsl:element>

      <xsl:element name="IntValue">
        <xsl:attribute name="name">ColumnWidth</xsl:attribute>
        <xsl:value-of select="ColumnWidth"/>
      </xsl:element>

      <xsl:element name="StringValue">
        <xsl:attribute name="name">DataType</xsl:attribute>
        <xsl:value-of select="DataType"/>
      </xsl:element>

      <xsl:element name="IntValue">
        <xsl:attribute name="name">IsNullable</xsl:attribute>
        <xsl:value-of select="IsNullable"/>
      </xsl:element>

      <xsl:element name="BoolValue">
        <xsl:attribute name="name">IsBinary</xsl:attribute>
        <xsl:value-of select="IsBinary"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

    <xsl:template match="Connection">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Connection</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ConnectionString</xsl:attribute>
				<xsl:value-of select="ConnectString"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">HandleId</xsl:attribute>
				<xsl:value-of select="HandleId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ConnectionType</xsl:attribute>
				<xsl:value-of select="ConnectType"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Status</xsl:attribute>
				<xsl:value-of select="Status"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">AccessType</xsl:attribute>
				<xsl:value-of select="AccessType"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">AutoCommit</xsl:attribute>
				<xsl:value-of select="AutoCommit"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">CreateTime</xsl:attribute>
				<xsl:value-of select="CreateTime"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LastUseTime</xsl:attribute>
				<xsl:value-of select="LastUseTime"/>
			</xsl:element>
			<xsl:call-template name="TimeStorage">
				<xsl:with-param name="name" select="'MaxIdleDuration'"/>
				<xsl:with-param name="time" select="MaxIdleDuration"/>
			</xsl:call-template>
		</xsl:element>
  </xsl:template>
  
  <xsl:template match="Handles">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HandlesItem</xsl:attribute>
			<xsl:for-each select="Connection">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">HandleItem</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ConnectionString</xsl:attribute>
						<xsl:value-of select="ConnectString"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">HandleId</xsl:attribute>
						<xsl:value-of select="HandleId"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ConnectionType</xsl:attribute>
						<xsl:value-of select="ConnectType"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">AccessType</xsl:attribute>
						<xsl:value-of select="AccessType"/>
					</xsl:element>
					<xsl:element name="BoolValue">
						<xsl:attribute name="name">AutoCommit</xsl:attribute>
						<xsl:value-of select="AutoCommit"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CreateTime</xsl:attribute>
						<xsl:value-of select="CreateTime"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">LastUseTime</xsl:attribute>
						<xsl:value-of select="LastUseTime"/>
					</xsl:element>
					<xsl:call-template name="TimeStorage">
						<xsl:with-param name="name" select="'MaxIdleDuration'"/>
						<xsl:with-param name="time" select="MaxIdleDuration"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
  </xsl:template>

  <xsl:template match="UncompressedData">
    <xsl:element name="ObjectValue">
      <xsl:attribute name="name">UncompressedDataItem</xsl:attribute>


      <!--All data is currently stored as strings-->
      <!--We *could* store with column names and attempt correct types but it's going to be hard-->
      <xsl:for-each select="TableRow">
        <xsl:element name="ObjectValue">
          <xsl:attribute name="name">TableRow</xsl:attribute>
          <xsl:for-each select="TableData">
            <xsl:element name="ObjectValue">
              <xsl:attribute name="name">TableData</xsl:attribute>
              <xsl:element name="StringValue">
                <xsl:attribute name="name">Data</xsl:attribute>
                <xsl:value-of select="."/>
              </xsl:element>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:for-each>
      
    </xsl:element>
  </xsl:template>
  
</xsl:transform>