<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name = "StorageObjects">
			<xsl:apply-templates select = "GrDo_FileScanner"/>
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="GrDo_FileScanner">
		<xsl:apply-templates select="GrDoFileEntry" />
		<xsl:apply-templates select="GrDoFileInfoComplete" />
				
	</xsl:template>
	
	<xsl:template match="GrDoFileInfoComplete">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TotalFiles</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesScanned</xsl:attribute>
				<xsl:value-of select="@filesScanned" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesReturned</xsl:attribute>
				<xsl:value-of select="@filesReturned" />
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GrDoPESection">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">PESection</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionName</xsl:attribute>
				<xsl:value-of select="@SectionName" />
			</xsl:element>			
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Characteristics</xsl:attribute>
				<xsl:value-of select="@Characteristics" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SizeofRawData</xsl:attribute>
				<xsl:value-of select="@SizeofRawData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">VirtualAddress</xsl:attribute>
				<xsl:value-of select="@VirtualAddress" />
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GrDoImportsDLL">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ImportsDLL</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DLLName</xsl:attribute>
				<xsl:value-of select="@DLLName" />
			</xsl:element>		
			<xsl:apply-templates select="GrDoImportedFunction" />
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GrDoImportedFunction">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ImportedFunction</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">functionName</xsl:attribute>
				<xsl:value-of select="@functionName" />
			</xsl:element>		
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="GrDoFilePEData">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">GrDoPEInformation</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Dos_magic</xsl:attribute>
				<xsl:value-of select="@Dos_magic" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Dos_lfanew</xsl:attribute>
				<xsl:value-of select="@Dos_lfanew" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Machine</xsl:attribute>
				<xsl:value-of select="@NT_Machine" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberofSections</xsl:attribute>
				<xsl:value-of select="@NT_NumberofSections" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_TimeDateStamp</xsl:attribute>
				<xsl:value-of select="@NT_TimeDateStamp" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberofSymbols</xsl:attribute>
				<xsl:value-of select="@NT_NumberofSymbols" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfOptionalHeader</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfOptionalHeader" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Characteristics</xsl:attribute>
				<xsl:value-of select="@NT_Characteristics" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Magic</xsl:attribute>
				<xsl:value-of select="@NT_Magic" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorLinkerVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorLinkerVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfCode</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfCode" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfInitializedData</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfInitializedData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfUninitializedData</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfUninitializedData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_AddressOfEntryPoint</xsl:attribute>
				<xsl:value-of select="@NT_AddressOfEntryPoint" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_BaseOfCode</xsl:attribute>
				<xsl:value-of select="@NT_BaseOfCode" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_BaseOfData</xsl:attribute>
				<xsl:value-of select="@NT_BaseOfData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_ImageBase</xsl:attribute>
				<xsl:value-of select="@NT_ImageBase" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SectionAlignment</xsl:attribute>
				<xsl:value-of select="@NT_SectionAlignment" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_FileAlignment</xsl:attribute>
				<xsl:value-of select="@NT_FileAlignment" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorOperatingSystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorOperatingSystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorOperatingSystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorOperatingSystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorImageVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorImageVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorImageVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorImageVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorSubsystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorSubsystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorSubsystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorSubsystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Win32VersionValue</xsl:attribute>
				<xsl:value-of select="@NT_Win32VersionValue" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfImage</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfImage" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeaders</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeaders" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_CheckSum</xsl:attribute>
				<xsl:value-of select="@NT_CheckSum" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Subsystem</xsl:attribute>
				<xsl:value-of select="@NT_Subsystem" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_DllCharacteristics</xsl:attribute>
				<xsl:value-of select="@NT_DllCharacteristics" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfStackReserve</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfStackReserve" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfStackCommit</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfStackCommit" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeapReserve</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeapReserve" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeapCommit</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeapCommit" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_LoaderFlags</xsl:attribute>
				<xsl:value-of select="@NT_LoaderFlags" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberOfRvaAndSizes</xsl:attribute>
				<xsl:value-of select="@NT_NumberOfRvaAndSizes" />
			</xsl:element>
			
			<xsl:apply-templates select="GrDoPESection" />
			<xsl:apply-templates select="GrDoImportsDLL" />

			
		</xsl:element>
	</xsl:template>	


	<xsl:template match="GrDoFileEntry">
		
		<xsl:element name="ObjectValue">
			
			<xsl:attribute name="name">FileEntry</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">FileStatus</xsl:attribute>
				<xsl:value-of select="@FileStatus" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Score</xsl:attribute>
				<xsl:value-of select="@score" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Malicious Score</xsl:attribute>
				<xsl:value-of select="@MaliciousScore" />
			</xsl:element>			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">FileName</xsl:attribute>
				<xsl:value-of select="@FileName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DllExportName</xsl:attribute>
				<xsl:value-of select="@DllExportName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ResourceOriginalFileName</xsl:attribute>
				<xsl:value-of select="@ResourceOriginalFileName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SignerName</xsl:attribute>
				<xsl:value-of select="@SignerName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">RootSignerName</xsl:attribute>
				<xsl:value-of select="@RootSignerName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwEntropy</xsl:attribute>
				<xsl:value-of select="@dwEntropy"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwLinkerVersion</xsl:attribute>
				<xsl:value-of select="@dwLinkerVersion"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwComputedChecksum</xsl:attribute>
				<xsl:value-of select="@dwComputedChecksum"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwEmbeddedChecksum</xsl:attribute>
				<xsl:value-of select="@dwEmbeddedChecksum"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Signed</xsl:attribute>
				<xsl:value-of select="@Signed"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Packed</xsl:attribute>
				<xsl:value-of select="@Packed"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">PEChecksum</xsl:attribute>
				<xsl:value-of select="@PEChecksum"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">HeaderSize</xsl:attribute>
				<xsl:value-of select="@HeaderSize"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">TimeStamp</xsl:attribute>
				<xsl:value-of select="@TimeStamp"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ExportTimeStamp</xsl:attribute>
				<xsl:value-of select="@ExportTimeStamp"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ResourceTimeStamp</xsl:attribute>
				<xsl:value-of select="@ResourceTimeStamp"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SignedTimeStamp</xsl:attribute>
				<xsl:value-of select="@SignedTimeStamp"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">CacheMatch</xsl:attribute>
				<xsl:value-of select="@CacheMatch"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SectionOrdering</xsl:attribute>
				<xsl:value-of select="@SectionOrdering"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SectionNames</xsl:attribute>
				<xsl:value-of select="@SectionNames"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Relocatable</xsl:attribute>
				<xsl:value-of select="@Relocatable"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NameMatch</xsl:attribute>
				<xsl:value-of select="@NameMatch"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ExportNameMatch</xsl:attribute>
				<xsl:value-of select="@ExportNameMatch"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">DotNet</xsl:attribute>
				<xsl:value-of select="@DotNet"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SizeOfCode</xsl:attribute>
				<xsl:value-of select="@SizeOfCode"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Linker</xsl:attribute>
				<xsl:value-of select="@Linker"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LinkerVersionTime</xsl:attribute>
				<xsl:value-of select="@LinkerVersionTime"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RegPersist</xsl:attribute>
				<xsl:value-of select="@RegPersist"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Protected</xsl:attribute>
				<xsl:value-of select="@Protected"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">TailData</xsl:attribute>
				<xsl:value-of select="@TailData"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NoVersionInfo</xsl:attribute>
				<xsl:value-of select="@NoVersionInfo"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">HijackedService</xsl:attribute>
				<xsl:value-of select="@HijackedService"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Keylogger</xsl:attribute>
				<xsl:value-of select="@Keylogger"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">InvalidAttributes</xsl:attribute>
				<xsl:value-of select="@InvalidAttributes"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">InvalidDrvLoc</xsl:attribute>
				<xsl:value-of select="@InvalidDrvLoc"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NoResources</xsl:attribute>
				<xsl:value-of select="@NoResources"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">IsHookTarget</xsl:attribute>
				<xsl:value-of select="@IsHookTarget"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ResData</xsl:attribute>
				<xsl:value-of select="@ResData"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NoDescription</xsl:attribute>
				<xsl:value-of select="@NoDescription"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ADSFileName</xsl:attribute>
				<xsl:value-of select="@ADSFileName"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">FileType</xsl:attribute>
				<xsl:value-of select="@FileType"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">IsPE</xsl:attribute>
				<xsl:value-of select="@IsPE"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Is64</xsl:attribute>
				<xsl:value-of select="@Is64"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">MajorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@MajorLinkerVersion"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">MinorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@MinorLinkerVersion"/>
			</xsl:element>		
			
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwSize</xsl:attribute>
				<xsl:value-of select="@dwSize"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwCalculatedFileSize</xsl:attribute>
				<xsl:value-of select="@dwCalculatedFileSize"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwExportCount</xsl:attribute>
				<xsl:value-of select="@dwExportCount"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwImportCount</xsl:attribute>
				<xsl:value-of select="@dwImportCount"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwImportCount</xsl:attribute>
				<xsl:value-of select="@dwImportCount"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwOSMajorVersion</xsl:attribute>
				<xsl:value-of select="@dwOSMajorVersion"/>
			</xsl:element>						
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwOSMinorVersion</xsl:attribute>
				<xsl:value-of select="@dwOSMinorVersion"/>
			</xsl:element>						
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="fileLinkerTime"/>
					<xsl:with-param name="var"  select="'fileLinkerTime'"/>
			</xsl:call-template>							
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="fileExportLinkerTime"/>
					<xsl:with-param name="var"  select="'fileExportLinkerTime'"/>
			</xsl:call-template>							
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="fileResourceLinkerTime"/>
					<xsl:with-param name="var"  select="'fileResourceLinkerTime'"/>
			</xsl:call-template>										
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="fileSignedTime"/>
					<xsl:with-param name="var"  select="'fileSignedTime'"/>
			</xsl:call-template>										
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="fileDiskCreationTime"/>
					<xsl:with-param name="var"  select="'fileDiskCreationTime'"/>
			</xsl:call-template>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SignedStatus</xsl:attribute>
				<xsl:value-of select="@SignedStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">MSStatus</xsl:attribute>
				<xsl:value-of select="@MSStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DotNetStatus</xsl:attribute>
				<xsl:value-of select="@DotNetStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">PackedStatus</xsl:attribute>
				<xsl:value-of select="@PackedStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">HeaderSizeStatus</xsl:attribute>
				<xsl:value-of select="@HeaderSizeStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionNamesStatus</xsl:attribute>
				<xsl:value-of select="@SectionNamesStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionOrderingStatus</xsl:attribute>
				<xsl:value-of select="@SectionOrderingStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SizeOfCodeStatus</xsl:attribute>
				<xsl:value-of select="@SizeOfCodeStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">PEChecksumStatus</xsl:attribute>
				<xsl:value-of select="@PEChecksumStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LinkerStatus</xsl:attribute>
				<xsl:value-of select="@LinkerStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LinkerVersionTimeStatus</xsl:attribute>
				<xsl:value-of select="@LinkerVersionTimeStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TimeStampStatus</xsl:attribute>
				<xsl:value-of select="@TimeStampStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ExportTimeStampStatus</xsl:attribute>
				<xsl:value-of select="@ExportTimeStampStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">CacheMatchStatus</xsl:attribute>
				<xsl:value-of select="@CacheMatchStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NameMatchStatus</xsl:attribute>
				<xsl:value-of select="@NameMatchStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">RelocatableStatus</xsl:attribute>
				<xsl:value-of select="@RelocatableStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">InvalidAttributesStatus</xsl:attribute>
				<xsl:value-of select="@InvalidAttributesStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">InvalidDrvLocStatus</xsl:attribute>
				<xsl:value-of select="@InvalidDrvLocStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NoResourcesStatus</xsl:attribute>
				<xsl:value-of select="@NoResourcesStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ResDataStatus</xsl:attribute>
				<xsl:value-of select="@ResDataStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TailDataStatus</xsl:attribute>
				<xsl:value-of select="@TailDataStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NoVersionInfoStatus</xsl:attribute>
				<xsl:value-of select="@NoVersionInfoStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ADSFileNameStatus</xsl:attribute>
				<xsl:value-of select="@ADSFileNameStatus" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">KeyloggerStatus</xsl:attribute>
				<xsl:value-of select="@KeyloggerStatus" />
			</xsl:element>
			<xsl:apply-templates select="GrDoFilePEData" />
			
			<xsl:for-each select="Hash">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Hash</xsl:attribute>
					
					<xsl:element name="IntValue">
						<xsl:attribute name="name">Size</xsl:attribute>
						<xsl:value-of select="@size"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="@type"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Value</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
		</xsl:element>
		
		
	</xsl:template>	


		
</xsl:transform>