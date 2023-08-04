Select *
From PortfolioProjectCovid.dbo.NashvilleHousing$



--Standardizing date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjectCovid.dbo.NashvilleHousing$

Update NashvilleHousing$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address data

Select *
From PortfolioProjectCovid.dbo.NashvilleHousing$
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectCovid.dbo.NashvilleHousing$ a
JOIN PortfolioProjectCovid.dbo.NashvilleHousing$ b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  Where a.PropertyAddress is null


  Update a
  SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  From PortfolioProjectCovid.dbo.NashvilleHousing$ a
JOIN PortfolioProjectCovid.dbo.NashvilleHousing$ b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]



--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjectCovid.dbo.NashvilleHousing$
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProjectCovid.dbo.NashvilleHousing$

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


Select *
From PortfolioProjectCovid.dbo.NashvilleHousing$



--Alternate way to split out address

Select OwnerAddress
From PortfolioProjectCovid.dbo.NashvilleHousing$

Select
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
From PortfolioProjectCovid.dbo.NashvilleHousing$


ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)


Select *
From PortfolioProjectCovid.dbo.NashvilleHousing$



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectCovid.dbo.NashvilleHousing$
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjectCovid.dbo.NashvilleHousing$


Update NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjectCovid.dbo.NashvilleHousing$



--Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num

From PortfolioProjectCovid.dbo.NashvilleHousing$
)

--DELETE
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--Delete Unused Columns

Select *
From PortfolioProjectCovid.dbo.NashvilleHousing$

ALTER TABLE PortfolioProjectCovid.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjectCovid.dbo.NashvilleHousing$
DROP COLUMN SaleDate